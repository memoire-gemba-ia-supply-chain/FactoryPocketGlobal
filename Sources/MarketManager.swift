import Foundation
import SwiftUI
import os

private let logger = Logger(subsystem: "com.anass.FactoryPocketGlobal", category: "MarketManager")

// MARK: - Models

struct MarketItem: Codable, Identifiable {
    let ticker: String
    let price: Double
    let trend: Double
    let name: String
    let currency: String?
    let unit: String?      // e.g. "USD/bbl", "USD/oz", "¢/lb", "¢/bu"
    
    var id: String { ticker }
}

struct MarketData: Codable {
    let lastUpdate: String
    let currencies: [MarketItem]
    let energy: [MarketItem]
    let rates: [String: Double]
    let metals: [MarketItem]
    let indices: [MarketItem]
    let agriculture: [MarketItem]
    
    enum CodingKeys: String, CodingKey {
        case lastUpdate = "last_update"
        case currencies, energy, metals, rates
        case indices, agriculture
    }
    
    // Allow missing keys for backward compatibility
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdate  = try c.decode(String.self, forKey: .lastUpdate)
        currencies  = try c.decodeIfPresent([MarketItem].self, forKey: .currencies)  ?? []
        energy      = try c.decodeIfPresent([MarketItem].self, forKey: .energy)      ?? []
        rates       = try c.decodeIfPresent([String: Double].self, forKey: .rates)   ?? [:]
        metals      = try c.decodeIfPresent([MarketItem].self, forKey: .metals)      ?? []
        indices     = try c.decodeIfPresent([MarketItem].self, forKey: .indices)     ?? []
        agriculture = try c.decodeIfPresent([MarketItem].self, forKey: .agriculture) ?? []
    }
    
    // Manual memberwise init for mock data
    init(lastUpdate: String, currencies: [MarketItem], energy: [MarketItem],
         metals: [MarketItem], indices: [MarketItem], rates: [String: Double] = [:],
         agriculture: [MarketItem]) {
        self.lastUpdate  = lastUpdate
        self.currencies  = currencies
        self.energy      = energy
        self.rates       = rates
        self.metals      = metals
        self.indices     = indices
        self.agriculture = agriculture
    }
}

// MARK: - Task Holder

/// A helper class to manage a task and cancel it on deinit.
/// This avoids isolation issues when an @MainActor class needs to cancel a task in its non-isolated deinit.
final class TaskHolder: @unchecked Sendable {
    private let taskRef = NSRecursiveLock()
    private var _task: Task<Void, Never>?
    
    var task: Task<Void, Never>? {
        get { taskRef.withLock { _task } }
        set { taskRef.withLock { _task = newValue } }
    }
    
    func cancel() {
        taskRef.withLock {
            _task?.cancel()
            _task = nil
        }
    }
    
    deinit {
        _task?.cancel()
    }
}

// MARK: - Market Manager

@MainActor
@Observable
final class MarketManager {
    
    static let shared = MarketManager()
    
    var data: MarketData?
    var isLoading: Bool = false
    var lastFetchDate: Date?
    var auditStatus: String = ""
    var dataIsStale: Bool = false
    
    var exchangerRates: [String: Double] {
        data?.rates ?? [:]
    }
    
    /// How long ago data was refreshed, human-readable
    var lastUpdateText: String {
        guard let date = lastFetchDate else { return L10n.never }
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 1   { return L10n.justNow }
        if minutes < 60  { return L10n.minutesAgo(minutes) }
        let hours = minutes / 60
        if hours < 24    { return L10n.hoursAgo(hours) }
        return L10n.daysAgo(hours / 24)
    }
    
    // CONFIGURE: Replace with your actual GitHub raw URL before App Store submission
    private static let dataURLString = "https://raw.githubusercontent.com/memoire-gemba-ia-supply-chain/FactoryPocketGlobal/main/Backend/market_data.json"
    private var dataURL: URL? { URL(string: Self.dataURLString) }
    static let cacheKey = "fpg_market_cache"
    private var storageKey: String { Self.cacheKey }
    // Smart polling + cache guardrails.
    private let maxCacheSize = 512_000  // 512 KB max cache size
    private let refreshIntervalSeconds: TimeInterval = 2 * 60 * 60
    private let refreshToleranceSeconds: TimeInterval = 20 * 60
    
    private let refreshTaskHolder = TaskHolder()
    
    private init() {
        loadFromCache()
        startAutoRefresh()
    }
    
    // ── Auto-refresh Task ────────────────────────
    
    // ── Foreground Refresh Check ─────────────────
    
    /// Called when app becomes active.
    /// Triggers refresh if data is missing or older than the expected cadence.
    func checkDataFreshness() {
        let referenceDate = data.flatMap { parseLastUpdateDate($0.lastUpdate) } ?? lastFetchDate
        guard let last = referenceDate else {
            // No data at all -> fetch immediately
            Task { await refreshMarketData() }
            return
        }
        
        let elapsed = Date().timeIntervalSince(last)
        if elapsed > (refreshIntervalSeconds + refreshToleranceSeconds) {
            logger.info("Data is stale (\(Int(elapsed/60)) min old), triggering refresh on open.")
            Task { await refreshMarketData() }
        }
    }
    
    // ── Auto-refresh Task (Smart Polling) ────────
    
    private func startAutoRefresh() {
        refreshTaskHolder.cancel()
        refreshTaskHolder.task = Task {
            while !Task.isCancelled {
                // Calculate delay to next synchronized slot (EvenHour:15 UTC).
                let delay = timeIntervalToNextRefresh()
                logger.info("Next market sync in \(Int(delay/60)) min")
                
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                // Refresh data if not cancelled
                if !Task.isCancelled {
                    await refreshMarketData()
                }
            }
        }
    }
    
    /// Calculates seconds until the next UTC "Even Hour:15" (e.g. 02:15, 04:15...).
    /// The workflow runs at Even Hour:05 UTC; app refresh at :15 avoids fetching
    /// the previous snapshot while the bot is still updating files.
    private func timeIntervalToNextRefresh() -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let now = Date()
        
        // Check slots for today: 00:15, 02:15, ... 22:15 UTC
        let evenHours = Array(stride(from: 0, through: 22, by: 2))
        
        for h in evenHours {
            if let date = calendar.date(bySettingHour: h, minute: 15, second: 0, of: now),
               date > now {
                return date.timeIntervalSince(now)
            }
        }
        
        // If none found today, target 00:15 tomorrow UTC.
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let next = calendar.date(bySettingHour: 0, minute: 15, second: 0, of: tomorrow) {
            return next.timeIntervalSince(now)
        }
        
        // Fallback safe default (1 hour)
        return 3600
    }
    
    // ── Data Loading ──────────────────────────────
    
    func loadFromCache() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(MarketData.self, from: savedData) {
            self.lastFetchDate = parseLastUpdateDate(decoded.lastUpdate)
            let freshness = checkFreshness(decoded.lastUpdate)
            switch freshness {
            case .fresh:
                self.data = decoded
                self.dataIsStale = false
                self.auditStatus = L10n.dataVerified
            case .stale:
                self.data = decoded
                self.dataIsStale = true
                self.auditStatus = L10n.cacheStale
                logger.info("Cache accepted as stale")
            case .rejected:
                self.data = nil
                self.dataIsStale = true
                self.auditStatus = L10n.cacheTooOld
                logger.info("Cache rejected — too old")
            }
        }
    }
    
    @MainActor
    func refreshMarketData() async {
        guard !isLoading else { return }
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            guard let url = dataURL else {
                logger.error("Invalid data URL")
                loadFromBundle()
                return
            }
            let (fetchData, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(MarketData.self, from: fetchData)
            
            // ── Run Audit Pipeline ──
            if let audited = auditData(decoded) {
                self.data = audited
                if auditStatus.isEmpty {
                    self.auditStatus = L10n.dataVerified
                }
                // Only cache if data is within size limit
                if fetchData.count <= maxCacheSize {
                    UserDefaults.standard.set(fetchData, forKey: storageKey)
                }
                self.lastFetchDate = parseLastUpdateDate(audited.lastUpdate) ?? Date()
            } else {
                logger.warning("Fetched data rejected by audit")
                // Fallback to bundle if rejected and no previous data
                if data == nil {
                    loadFromBundle()
                }
            }
            
        } catch {
            logger.error("Market fetch failed: \(error.localizedDescription)")
            if data == nil {
                loadFromBundle()
            }
        }
    }
    
    private func loadFromBundle() {
        let candidates: [URL?] = [
            Bundle.module.url(forResource: "market_data", withExtension: "json"),
            Bundle.module.url(forResource: "market_data", withExtension: "json", subdirectory: "Backend"),
            Bundle.module.url(forResource: "Backend/market_data", withExtension: "json")
        ]
        guard
            let url = candidates.compactMap({ $0 }).first,
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(MarketData.self, from: data)
        else {
            logger.error("Failed to load local bundle data")
            setMockData()
            return
        }
        
        self.data = decoded
        // Mark as stale since it's build-time data
        self.dataIsStale = true 
        self.auditStatus = L10n.cacheStale
        self.lastFetchDate = parseLastUpdateDate(decoded.lastUpdate)
    }
    
    // ── Data Audit Pipeline ──────────────────────
    
    /// Validates scraped data before it reaches the UI.
    /// Returns audited MarketData, or nil if data is rejected entirely.
    private func auditData(_ raw: MarketData) -> MarketData? {
        self.dataIsStale = false
        self.auditStatus = ""
        
        // 1) Freshness check: prefer today's data, accept up to 48h as stale
        let freshness = checkFreshness(raw.lastUpdate)
        if freshness == .rejected {
            self.dataIsStale = true
            self.auditStatus = L10n.dataTooOld
            logger.info("Audit rejected — lastUpdate too old: \(raw.lastUpdate)")
            return nil
        }
        if freshness == .stale {
            self.dataIsStale = true
            self.auditStatus = L10n.staleNotToday
        }
        
        // 2) Audit each category: filter invalid items
        let currencies  = auditItems(raw.currencies,  label: "Currencies")
        let energy      = auditItems(raw.energy,      label: "Energy")
        let metals      = auditItems(raw.metals,      label: "Metals")
        let indices     = auditItems(raw.indices,     label: "Indices")
        let agriculture = auditItems(raw.agriculture, label: "Agriculture")
        
        // 3) Completeness: at least 3 categories must have data
        let filledCategories = [currencies, energy, metals, indices, agriculture]
            .filter { !$0.isEmpty }.count
        guard filledCategories >= 3 else {
            self.auditStatus = L10n.incompleteData(filledCategories)
            logger.warning("Audit rejected — only \(filledCategories) categories have data")
            return nil
        }
        
        // 4) Audit exchange rates
        let validatedRates = auditRates(raw.rates)
        
        return MarketData(
            lastUpdate: raw.lastUpdate,
            currencies: currencies,
            energy: energy,
            metals: metals,
            indices: indices,
            rates: validatedRates,
            agriculture: agriculture
        )
    }
    
    /// Filters a list of MarketItems: removes invalid prices, absurd trends, duplicates.
    private func auditItems(_ items: [MarketItem], label: String) -> [MarketItem] {
        var seenTickers = Set<String>()
        var clean: [MarketItem] = []
        
        for item in items {
            // Price must be positive and finite
            guard item.price > 0, !item.price.isNaN, !item.price.isInfinite else {
                logger.debug("\(label): dropped \(item.ticker) — invalid price \(item.price)")
                continue
            }
            // Trend must be within ±50%
            guard abs(item.trend) <= 50 else {
                logger.debug("\(label): dropped \(item.ticker) — absurd trend \(item.trend)%")
                continue
            }
            // No duplicate tickers
            guard !seenTickers.contains(item.ticker) else {
                logger.debug("\(label): dropped duplicate \(item.ticker)")
                continue
            }
            seenTickers.insert(item.ticker)
            clean.append(item)
        }
        return clean
    }
    
    // ── Rate-specific validation ─────────────────────
    
    /// Known realistic bounds for key currencies (1 USD = ? Currency)
    private static let rateBounds: [String: ClosedRange<Double>] = [
        "EUR": 0.50...1.50,    "GBP": 0.40...1.30,
        "JPY": 70...250,       "CAD": 0.90...2.00,
        "AUD": 0.90...2.20,    "CNY": 4.0...10.0,
        "CHF": 0.50...1.50,    "MAD": 7.0...14.0,
        "INR": 50...130,       "BRL": 3.0...8.0,
        "AED": 3.0...4.5,      "SAR": 3.0...4.5,
    ]
    
    /// Validates exchange rates block.
    /// Removes rates that fail bounds checks. Returns cleaned rates dict.
    private func auditRates(_ rates: [String: Double]) -> [String: Double] {
        // Must have USD = 1.0
        guard rates["USD"] == 1.0 else {
            logger.warning("Rates audit: USD != 1.0 — rejecting rates")
            self.auditStatus = L10n.invalidRates
            return [:]
        }
        
        // Must have at least 10 currencies
        guard rates.count >= 10 else {
            logger.warning("Rates audit: only \(rates.count) rates (min 10)")
            self.auditStatus = L10n.insufficientRates(rates.count)
            return [:]
        }
        
        // Filter out rates that fail bounds check
        var clean = rates
        for (code, range) in Self.rateBounds {
            if let rate = clean[code], !range.contains(rate) {
                logger.debug("Rates audit: \(code) = \(rate) out of bounds \(range)")
                clean.removeValue(forKey: code)
            }
        }
        
        return clean
    }
    
    private enum DataFreshness { case fresh, stale, rejected }

    /// Parses server date formats used by the scraper (ISO8601 with/without micros).
    private func parseLastUpdateDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            return date
        }

        let microDate = DateFormatter()
        microDate.locale = Locale(identifier: "en_US_POSIX")
        microDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        if let date = microDate.date(from: dateString) {
            return date
        }

        if dateString.count >= 10 {
            let shortDate = DateFormatter()
            shortDate.dateFormat = "yyyy-MM-dd"
            shortDate.locale = Locale(identifier: "en_US_POSIX")
            return shortDate.date(from: String(dateString.prefix(10)))
        }

        return nil
    }
    
    /// Checks data freshness with 3-tier system:
    /// - fresh: data is from today
    /// - stale: data is 1-48h old (show with warning)
    /// - rejected: data is >48h old
    private func checkFreshness(_ dateString: String) -> DataFreshness {
        guard let date = parseLastUpdateDate(dateString) else {
            logger.warning("Could not parse lastUpdate: \(dateString)")
            return .rejected
        }
        
        if Calendar.current.isDateInToday(date) {
            return .fresh
        }
        
        let age = Date().timeIntervalSince(date)
        if age <= 48 * 3600 {
            return .stale
        }
        
        return .rejected
    }
    
    private func setMockData() {
        let mock = MarketData(
            lastUpdate: ISO8601DateFormatter().string(from: Date()),
            // International pairs first, MAD pairs after
            currencies: [
                MarketItem(ticker: "EURUSD=X", price: 1.1873, trend: -0.17, name: "EUR / USD", currency: nil, unit: nil),
                MarketItem(ticker: "USDJPY=X", price: 153.05, trend: 0.12, name: "USD / JPY", currency: nil, unit: nil),
                MarketItem(ticker: "GBPUSD=X", price: 1.37,   trend: 0.08, name: "GBP / USD", currency: nil, unit: nil),
                MarketItem(ticker: "USDCNY=X", price: 6.91,   trend: -0.05, name: "USD / CNY", currency: nil, unit: nil),
                MarketItem(ticker: "DX-Y.NYB", price: 99.50,  trend: -0.20, name: "US Dollar Index", currency: nil, unit: "pts"),
                MarketItem(ticker: "USDMAD=X", price: 9.11,   trend: 0.03, name: "USD / MAD", currency: nil, unit: nil),
                MarketItem(ticker: "EURMAD=X", price: 10.83,  trend: -0.10, name: "EUR / MAD", currency: nil, unit: nil),
                MarketItem(ticker: "GBPMAD=X", price: 12.50,  trend: 0.05,  name: "GBP / MAD", currency: nil, unit: nil),
            ],
            energy: [
                MarketItem(ticker: "BZ=F", price: 69.58,  trend: 1.13, name: "Brent Crude",   currency: "USD", unit: "USD/bbl"),
                MarketItem(ticker: "CL=F", price: 64.90,  trend: 1.48, name: "WTI Crude",     currency: "USD", unit: "USD/bbl"),
                MarketItem(ticker: "NG=F", price: 3.23,   trend: 3.82, name: "Natural Gas",   currency: "USD", unit: "USD/MMBtu"),
                MarketItem(ticker: "HO=F", price: 2.15,   trend: 0.90, name: "Heating Oil",   currency: "USD", unit: "USD/gal"),
                MarketItem(ticker: "RB=F", price: 1.98,   trend: 0.75, name: "Gasoline RBOB", currency: "USD", unit: "USD/gal"),
            ],

            metals: [
                MarketItem(ticker: "GC=F",  price: 5050.0,  trend: 0.50,  name: "Gold",      currency: "USD", unit: "USD/oz"),
                MarketItem(ticker: "SI=F",  price: 82.43,   trend: 2.20,  name: "Silver",    currency: "USD", unit: "USD/oz"),
                MarketItem(ticker: "HG=F",  price: 5.99,    trend: 1.31,  name: "Copper",    currency: "USD", unit: "USD/lb"),
                MarketItem(ticker: "ALI=F", price: 3120.0,  trend: 0.59,  name: "Aluminium", currency: "USD", unit: "USD/t"),
                MarketItem(ticker: "PL=F",  price: 1180.0,  trend: 0.80,  name: "Platinum",  currency: "USD", unit: "USD/oz"),
                MarketItem(ticker: "PA=F",  price: 980.0,   trend: -0.30, name: "Palladium", currency: "USD", unit: "USD/oz"),
            ],
            indices: [
                MarketItem(ticker: "^GSPC",     price: 6941.47,  trend: -0.30, name: "S&P 500",       currency: nil, unit: "pts"),
                MarketItem(ticker: "^DJI",      price: 50121.40, trend: -0.13,  name: "Dow Jones",     currency: nil, unit: "pts"),
                MarketItem(ticker: "^IXIC",     price: 23066.47, trend: -0.16, name: "Nasdaq",        currency: nil, unit: "pts"),
                MarketItem(ticker: "^STOXX50E", price: 6086.30,   trend: 0.84, name: "Euro Stoxx 50", currency: nil, unit: "pts"),
                MarketItem(ticker: "^FTSE",     price: 10485.69,  trend: 0.13,  name: "FTSE 100",      currency: nil, unit: "pts"),
                MarketItem(ticker: "^N225",     price: 57639.84,  trend: -0.02,  name: "Nikkei 225",    currency: nil, unit: "pts"),
            ],
            rates: [
                "USD": 1.0,
                "EUR": 0.8416,
                "GBP": 0.7334,
                "JPY": 152.82,
                "CAD": 1.3573,
                "AUD": 1.4053,
                "CNY": 6.9002,
                "CHF": 0.77,
                "HKD": 7.8156,
                "SGD": 1.2618,
                "SEK": 8.9026,
                "KRW": 1437.32,
                "NOK": 9.4868,
                "NZD": 1.6494,
                "INR": 90.61,
                "MXN": 17.1883,
                "TWD": 31.372,
                "ZAR": 15.9012,
                "BRL": 5.1754,
                "DKK": 6.2887,
                "PLN": 3.5492,
                "THB": 30.99,
                "IDR": 16810.0,
                "HUF": 320.44,
                "CZK": 20.4168,
                "ILS": 3.0692,
                "CLP": 852.02,
                "PHP": 58.069,
                "AED": 3.6728,
                "COP": 3664.52,
                "SAR": 3.7502,
                "MYR": 3.9075,
                "RON": 4.2864,
                "MAD": 9.138
            ],
            agriculture: [
                MarketItem(ticker: "SB=F", price: 13.85,   trend: -1.84, name: "Sugar #11",  currency: nil, unit: "¢/lb"),
                MarketItem(ticker: "KC=F", price: 292.57,  trend: -0.45, name: "Coffee",     currency: nil, unit: "¢/lb"),
                MarketItem(ticker: "CT=F", price: 62.13,   trend: 0.88,  name: "Cotton #2",  currency: nil, unit: "¢/lb"),
                MarketItem(ticker: "ZW=F", price: 538.29,  trend: 1.90,  name: "Wheat",      currency: nil, unit: "¢/bu"),
                MarketItem(ticker: "ZC=F", price: 429.97,  trend: -0.20, name: "Corn",       currency: nil, unit: "¢/bu"),
                MarketItem(ticker: "ZS=F", price: 1035.0,  trend: 0.30,  name: "Soybeans",   currency: nil, unit: "¢/bu"),
            ]
        )
        self.data = mock
        self.lastFetchDate = Date()
    }
}

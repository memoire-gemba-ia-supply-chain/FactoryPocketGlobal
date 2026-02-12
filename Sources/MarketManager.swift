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
    let unit: String?

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
        lastUpdate = try c.decode(String.self, forKey: .lastUpdate)
        currencies = try c.decodeIfPresent([MarketItem].self, forKey: .currencies) ?? []
        energy = try c.decodeIfPresent([MarketItem].self, forKey: .energy) ?? []
        rates = try c.decodeIfPresent([String: Double].self, forKey: .rates) ?? [:]
        metals = try c.decodeIfPresent([MarketItem].self, forKey: .metals) ?? []
        indices = try c.decodeIfPresent([MarketItem].self, forKey: .indices) ?? []
        agriculture = try c.decodeIfPresent([MarketItem].self, forKey: .agriculture) ?? []
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
        if minutes < 1 { return L10n.justNow }
        if minutes < 60 { return L10n.minutesAgo(minutes) }
        let hours = minutes / 60
        if hours < 24 { return L10n.hoursAgo(hours) }
        return L10n.daysAgo(hours / 24)
    }

    // Remote-only source of truth for market data.
    private static let dataURLString =
        "https://raw.githubusercontent.com/memoire-gemba-ia-supply-chain/FactoryPocketGlobal/main/Backend/market_data.json"
    private var dataURL: URL? { URL(string: Self.dataURLString) }

    private let refreshIntervalSeconds: TimeInterval = 2 * 60 * 60
    private let refreshToleranceSeconds: TimeInterval = 20 * 60

    private let refreshTaskHolder = TaskHolder()

    private init() {
        startAutoRefresh()
    }

    /// Called when app becomes active.
    /// Triggers refresh if data is missing or older than the expected cadence.
    func checkDataFreshness() {
        let referenceDate = data.flatMap { parseLastUpdateDate($0.lastUpdate) } ?? lastFetchDate
        guard let last = referenceDate else {
            Task { await refreshMarketData() }
            return
        }

        let elapsed = Date().timeIntervalSince(last)
        if elapsed > (refreshIntervalSeconds + refreshToleranceSeconds) {
            logger.info("Data is stale (\(Int(elapsed / 60)) min old), triggering refresh on open.")
            Task { await refreshMarketData() }
        }
    }

    // MARK: - Auto Refresh

    private func startAutoRefresh() {
        refreshTaskHolder.cancel()
        refreshTaskHolder.task = Task {
            while !Task.isCancelled {
                let delay = timeIntervalToNextRefresh()
                logger.info("Next market sync in \(Int(delay / 60)) min")

                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
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

        let evenHours = Array(stride(from: 0, through: 22, by: 2))

        for hour in evenHours {
            if let date = calendar.date(bySettingHour: hour, minute: 15, second: 0, of: now),
               date > now {
                return date.timeIntervalSince(now)
            }
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let next = calendar.date(bySettingHour: 0, minute: 15, second: 0, of: tomorrow) {
            return next.timeIntervalSince(now)
        }

        return 3600
    }

    // MARK: - Remote Fetch

    @MainActor
    func refreshMarketData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            guard let url = dataURL else {
                logger.error("Invalid data URL")
                markOnlineUnavailable(reason: "invalid URL")
                return
            }

            let (fetchData, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(MarketData.self, from: fetchData)

            if let audited = auditData(decoded) {
                self.data = audited
                if auditStatus.isEmpty {
                    self.auditStatus = L10n.dataVerified
                }
                self.lastFetchDate = parseLastUpdateDate(audited.lastUpdate) ?? Date()
            } else {
                logger.warning("Fetched data rejected by audit")
                if data == nil {
                    markOnlineUnavailable(reason: "audit rejected")
                } else {
                    updateStalenessFromCurrentData()
                    if dataIsStale && auditStatus.isEmpty {
                        auditStatus = L10n.staleNotToday
                    }
                }
            }

        } catch {
            logger.error("Market fetch failed: \(error.localizedDescription)")
            if data == nil {
                markOnlineUnavailable(reason: error.localizedDescription)
            } else {
                updateStalenessFromCurrentData()
                if dataIsStale {
                    auditStatus = L10n.staleNotToday
                }
            }
        }
    }

    private func markOnlineUnavailable(reason: String) {
        dataIsStale = true
        auditStatus = L10n.marketUnavailable
        logger.warning("Online data unavailable: \(reason)")
    }

    private func updateStalenessFromCurrentData() {
        guard let current = data else {
            dataIsStale = true
            return
        }
        let freshness = checkFreshness(current.lastUpdate)
        dataIsStale = freshness != .fresh
    }

    // MARK: - Data Audit Pipeline

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
        let currencies = auditItems(raw.currencies, label: "Currencies")
        let energy = auditItems(raw.energy, label: "Energy")
        let metals = auditItems(raw.metals, label: "Metals")
        let indices = auditItems(raw.indices, label: "Indices")
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
            rates: validatedRates,
            metals: metals,
            indices: indices,
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

    // MARK: - Rate Validation

    /// Known realistic bounds for key currencies (1 USD = ? Currency)
    private static let rateBounds: [String: ClosedRange<Double>] = [
        "EUR": 0.50...1.50, "GBP": 0.40...1.30,
        "JPY": 70...250, "CAD": 0.90...2.00,
        "AUD": 0.90...2.20, "CNY": 4.0...10.0,
        "CHF": 0.50...1.50, "MAD": 7.0...14.0,
        "INR": 50...130, "BRL": 3.0...8.0,
        "AED": 3.0...4.5, "SAR": 3.0...4.5,
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
}

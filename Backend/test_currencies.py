#!/usr/bin/env python3
"""
Quick manual test: fetch all exchanger rates and show their values
alongside ECB reference for comparison.
"""
import yfinance as yf
import urllib.request
import xml.etree.ElementTree as ET

# ── ECB reference (USD-based) ────────────────────────────────
def get_ecb_usd_rates():
    url = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    req = urllib.request.Request(url, headers={"User-Agent": "FPG-Test/1.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        root = ET.fromstring(resp.read())
    ns = {"ecb": "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"}
    eur_rates = {"EUR": 1.0}
    for c in root.findall(".//ecb:Cube[@currency]", ns):
        eur_rates[c.attrib["currency"]] = float(c.attrib["rate"])
    eur_usd = eur_rates.get("USD", 0)
    if eur_usd <= 0: return {}
    return {k: round(v / eur_usd, 4) for k, v in eur_rates.items() if k != "USD"}

# ── yfinance test ────────────────────────────────────────────
currencies = ["EUR", "GBP", "JPY", "CAD", "AUD", "CNY", "CHF",
              "NZD", "MXN", "HKD", "SGD", "MAD", "INR", "BRL"]

pairs = {c: f"USD{c}=X" for c in currencies}
# EUR, GBP, AUD, NZD are inverted (ticker = XXXUSD=X)
inverted = {"EUR": "EURUSD=X", "GBP": "GBPUSD=X",
            "AUD": "AUDUSD=X", "NZD": "NZDUSD=X"}
pairs.update(inverted)

ecb = get_ecb_usd_rates()

print(f"{'Currency':<8} {'yfinance':<12} {'ECB ref':<12} {'Δ%':<8} Status")
print("-" * 52)

for code in currencies:
    ticker = pairs[code]
    invert = code in inverted
    try:
        data = yf.download(ticker, period="5d", interval="1d",
                           progress=False, timeout=10)
        if data.empty:
            print(f"{code:<8} {'N/A':<12} {ecb.get(code, 'N/A')!s:<12} {'—':<8} ❌ No data")
            continue
        if hasattr(data.columns, 'levels') and len(data.columns.levels) > 1:
            data.columns = data.columns.droplevel(1)
        price = float(data["Close"].iloc[-1])
        rate = (1.0 / price) if invert else price
        rate = round(rate, 4)

        ecb_rate = ecb.get(code)
        if ecb_rate:
            dev = abs(rate - ecb_rate) / ecb_rate * 100
            status = "✅" if dev < 3 else ("⚠️" if dev < 10 else "❌")
            print(f"{code:<8} {rate:<12.4f} {ecb_rate:<12.4f} {dev:<8.2f} {status}")
        else:
            print(f"{code:<8} {rate:<12.4f} {'N/A':<12} {'—':<8} ℹ️  No ECB ref")
    except Exception as e:
        print(f"{code:<8} ERROR: {e}")


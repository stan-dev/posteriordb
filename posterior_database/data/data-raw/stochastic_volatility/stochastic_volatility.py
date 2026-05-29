"""
Generate the data for the `stochastic_volatility` posterior in posteriordb.

Model: stochastic volatility model of Hoffman & Gelman (2014), "The No-U-Turn
Sampler", pp. 1614-1615. The Stan model receives the raw price series `y`
(length T) and computes the log-returns internally in `transformed data`.

The paper uses "3000 days of the S&P 500 index" but does not specify exact
dates, a ticker, or a data source. We therefore use a documented modern window
(2010-2022, excluding no period in particular but landing in a relatively calm
regime by construction of the 3000-day truncation) and download the index from
Yahoo Finance via yfinance. The raw download is cached to a CSV so the JSON can
be regenerated identically without re-hitting Yahoo's (unofficial) API.

Output: data/data/stochastic_volatility.json.zip
  -> contains stochastic_volatility.json with keys:
       T : int            number of trading days (prices)
       y : list[float]    closing price of the S&P 500 for each day, length T

Usage:
    python stochastic_volatility.py

Requires: yfinance, pandas
"""

import json
import os
import zipfile

import pandas as pd

# --- Configuration -----------------------------------------------------------

TICKER = "^GSPC"          # S&P 500 index on Yahoo Finance
START = "2010-01-01"      # modern, post-2008-crisis window
END = "2022-01-01"        # ends before the 2022 drawdown
N_DAYS = 3000             # number of prices T (Hoffman & Gelman use "3000 days")

# Paths are written relative to this script's location so it works regardless
# of the current working directory. The script lives in
# data/data-raw/stochastic_volatility/ and writes the zip into data/data/.
HERE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(HERE, "sp500_raw.csv")
# data-raw/stochastic_volatility/ -> data-raw/ -> data/
DATA_DIR = os.path.normpath(os.path.join(HERE, "..", "..", "data"))
JSON_NAME = "stochastic_volatility.json"
ZIP_PATH = os.path.join(DATA_DIR, "stochastic_volatility.json.zip")


# --- Step 1: get the raw price series (download once, then cache) ------------

def load_prices():
    if os.path.exists(CSV_PATH):
        print(f"Reading cached prices from {CSV_PATH}")
        df = pd.read_csv(CSV_PATH, parse_dates=["Date"])
    else:
        print(f"Downloading {TICKER} from Yahoo Finance ({START} -> {END})")
        import yfinance as yf
        raw = yf.download(
            TICKER, start=START, end=END, progress=False, auto_adjust=False
        )
        if raw.empty:
            raise RuntimeError(
                "Download returned no data. Yahoo's API may be temporarily "
                "unavailable; try again or supply sp500_raw.csv manually."
            )
        # yfinance can return a MultiIndex column when one ticker is requested;
        # flatten it and keep the closing price.
        close = raw["Close"]
        if isinstance(close, pd.DataFrame):
            close = close.iloc[:, 0]
        df = close.reset_index()
        df.columns = ["Date", "Close"]
        df.to_csv(CSV_PATH, index=False)
        print(f"Cached raw prices to {CSV_PATH} ({len(df)} rows)")
    return df


# --- Step 2: build T and y, then write the zipped JSON -----------------------

def main():
    df = load_prices()
    df = df.dropna(subset=["Close"]).sort_values("Date").reset_index(drop=True)

    if len(df) < N_DAYS:
        raise RuntimeError(
            f"Only {len(df)} trading days available; need {N_DAYS}. "
            "Widen the START/END window."
        )

    # Take the first N_DAYS trading days of the window.
    prices = df["Close"].iloc[:N_DAYS].astype(float).tolist()

    data = {
        "T": N_DAYS,
        "y": prices,
    }

    os.makedirs(DATA_DIR, exist_ok=True)
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(JSON_NAME, json.dumps(data))

    print(f"Wrote {ZIP_PATH}")
    print(f"  T = {data['T']}")
    print(f"  y: {len(data['y'])} prices, "
          f"range [{min(prices):.2f}, {max(prices):.2f}]")

    
if __name__ == "__main__":
    main()
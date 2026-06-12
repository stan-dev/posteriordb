import json
import os
import zipfile

import pandas as pd

# --- Configuration -----------------------------------------------------------

TICKER = "^GSPC"          # S&P 500 index on Yahoo Finance
START = "2010-01-01"
END = "2022-01-01"
N_DAYS = 3000             # number of prices T (Hoffman & Gelman use "3000 days")

HERE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(HERE, "sp500_raw.csv")
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
                "Download returned no data. Yahoo's API may be temporarily unavailable; try again or supply sp500_raw.csv manually."
            )
        # yfinance can return a MultiIndex column for a single ticker; flatten it.
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
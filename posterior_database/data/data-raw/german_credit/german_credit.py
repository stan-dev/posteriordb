#!/usr/bin/env python3
"""
Generate the posteriordb data set `german_credit`.

German credit data with 24 standardized numeric predictors, as used in
Hoffman & Gelman (2014), "The No-U-Turn Sampler", JMLR 15, Section 4.1.2.

Source:
  UCI Statlog (German Credit Data), file german.data-numeric
  https://archive.ics.uci.edu/dataset/144/statlog+german+credit+data
  24 numeric attributes + class column (1 = good, 2 = bad), 1000 rows.

Preprocessing:
  * y = 1 for good credit risk, 0 for bad.
  * The 24 predictors are standardized to mean 0 and variance 1 using the
    population SD (ddof = 0).

Output:
  german_credit.json       {"N": 1000, "D": 24, "X": [[...], ...], "y": [...]}
  german_credit.json.zip   zipped copy, as stored in posteriordb

Usage:
  python german_credit.py                             # downloads from UCI
  python german_credit.py --input german.data-numeric --outdir out/

Requires only numpy.
"""

import argparse
import hashlib
import json
import os
import urllib.request
import zipfile

import numpy as np

NAME = "german_credit"
UCI_URL = (
    "https://archive.ics.uci.edu/ml/machine-learning-databases/"
    "statlog/german/german.data-numeric"
)
N_EXPECTED = 1000
D_EXPECTED = 24


def load_raw(path=None):
    if path is not None:
        with open(path, "r") as f:
            text = f.read()
    else:
        print(f"Downloading {UCI_URL} ...")
        with urllib.request.urlopen(UCI_URL) as resp:
            text = resp.read().decode("ascii")

    rows = [line.split() for line in text.strip().splitlines() if line.strip()]
    raw = np.array(rows, dtype=float)
    if raw.shape != (N_EXPECTED, D_EXPECTED + 1):
        raise ValueError(
            f"Expected shape ({N_EXPECTED}, {D_EXPECTED + 1}), got {raw.shape}. "
            "Is this the german.data-numeric file (not german.data)?"
        )
    return raw


def standardize(M):
    mu = M.mean(axis=0)
    sd = M.std(axis=0, ddof=0)
    bad = np.where(sd < 1e-12)[0]
    if bad.size:
        raise ValueError(f"Zero-variance columns at indices {bad.tolist()}")
    return (M - mu) / sd


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--input", help="local path to german.data-numeric (else download)")
    p.add_argument("--outdir", default=".", help="output directory")
    args = p.parse_args()
    os.makedirs(args.outdir, exist_ok=True)

    raw = load_raw(args.input)
    cls = raw[:, D_EXPECTED].astype(int)
    if not set(np.unique(cls)) <= {1, 2}:
        raise ValueError(f"Unexpected class labels: {np.unique(cls)}")
    y = (cls == 1).astype(int)
    X = standardize(raw[:, :D_EXPECTED])

    data = {"N": int(X.shape[0]), "D": int(X.shape[1]), "X": X.tolist(), "y": y.tolist()}
    payload = json.dumps(data, separators=(",", ":"))

    json_path = os.path.join(args.outdir, f"{NAME}.json")
    with open(json_path, "w") as f:
        f.write(payload)
    with zipfile.ZipFile(json_path + ".zip", "w", compression=zipfile.ZIP_DEFLATED) as z:
        z.write(json_path, arcname=f"{NAME}.json")

    print(f"N = {len(y)}, good (y=1) = {y.sum()}, bad (y=0) = {len(y) - y.sum()}")
    print(f"X shape = {X.shape}")
    print(f"Wrote {json_path} and {json_path}.zip")
    print(f"sha256(json) = {hashlib.sha256(payload.encode()).hexdigest()}")


if __name__ == "__main__":
    main()

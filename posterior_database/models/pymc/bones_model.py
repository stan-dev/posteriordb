def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data as numpy arrays
    nChild = int(data['nChild'])
    nInd = int(data['nInd'])
    gamma = np.array(data['gamma'])  # shape: [nInd, 4]
    delta = np.array(data['delta'])  # shape: [nInd]
    ncat = np.array(data['ncat'])    # shape: [nInd]
    grade = np.array(data['grade'])  # shape: [nChild, nInd]

    # --- Precompute numpy data wrangling ---
    max_ncat = int(np.max(ncat))
    n_thresholds = max_ncat - 1  # max number of thresholds

    # Pad gamma to (nInd, n_thresholds) — already correct if gamma has enough columns
    # gamma may have shape (nInd, 4) but we only need (nInd, n_thresholds)
    gamma_padded = np.zeros((nInd, n_thresholds), dtype=np.float64)
    gamma_padded[:, :min(gamma.shape[1], n_thresholds)] = gamma[:, :n_thresholds]

    # Build a boolean mask for valid thresholds: (nInd, n_thresholds)
    # Indicator j has ncat[j]-1 valid thresholds (indices 0..ncat[j]-2)
    thresh_idx = np.arange(n_thresholds)[None, :]  # (1, n_thresholds)
    valid_thresh = thresh_idx < (ncat[:, None] - 1)  # (nInd, n_thresholds)

    # Precompute numpy index arrays and masks for likelihood
    cat_idx = np.arange(max_ncat)[None, :]            # (1, max_ncat)
    valid_cat = cat_idx < ncat[:, None]                # (nInd, max_ncat)
    valid_cat_3d = valid_cat[None, :, :]               # (1, nInd, max_ncat) broadcasts

    grade_0based = np.clip(grade - 1, 0, max_ncat - 1).astype(np.int64)

    child_idx = np.arange(nChild)[:, None]  # (nChild, 1)
    ind_idx = np.arange(nInd)[None, :]      # (1, nInd)

    obs_mask = (grade != -1).astype(np.float64)  # (nChild, nInd)

    with pm.Model() as model:
        # Prior
        theta = pm.Normal("theta", mu=0, sigma=36, shape=nChild)

        # Compute Q for all (child, indicator, threshold) via broadcasting
        # theta: (nChild,) -> (nChild, 1, 1)
        # gamma_padded: (nInd, n_thresholds) -> (1, nInd, n_thresholds)
        # delta: (nInd,) -> (1, nInd, 1)
        diff = theta[:, None, None] - gamma_padded[None, :, :]  # (nChild, nInd, n_thresholds)
        Q = pm.math.invlogit(delta[None, :, None] * diff)       # (nChild, nInd, n_thresholds)

        # Build category probabilities: shape (nChild, nInd, max_ncat)
        # p[..., 0]    = 1 - Q[..., 0]
        # p[..., k]    = Q[..., k-1] - Q[..., k]   for 1 <= k <= n_thresholds-1
        # p[..., last]  = Q[..., n_thresholds-1]
        #
        # We can construct this by:
        #   prepend a "1" before Q along the threshold axis
        #   append a "0" after Q along the threshold axis
        #   then p = prev - next
        ones = pt.ones((nChild, nInd, 1))
        zeros = pt.zeros((nChild, nInd, 1))
        Q_aug_upper = pt.concatenate([ones, Q], axis=2)    # (nChild, nInd, max_ncat)
        Q_aug_lower = pt.concatenate([Q, zeros], axis=2)   # (nChild, nInd, max_ncat)
        p = Q_aug_upper - Q_aug_lower                      # (nChild, nInd, max_ncat)

        # Mask invalid categories to a small positive value so log doesn't blow up
        # Clamp probabilities to avoid log(0)
        p_safe = pt.switch(valid_cat_3d, pt.maximum(p, 1e-20), 1.0)

        # Compute log probabilities for all categories: (nChild, nInd, max_ncat)
        log_p = pt.log(p_safe)

        # Extract the log prob for the observed grade using advanced indexing
        selected_log_p = log_p[child_idx, ind_idx, grade_0based]  # (nChild, nInd)
        total_log_prob = pt.sum(selected_log_p * obs_mask)

        # Add likelihood potential
        pm.Potential("likelihood", total_log_prob)

    return model

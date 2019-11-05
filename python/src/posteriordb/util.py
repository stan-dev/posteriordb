def drop_keys(dct, keys_to_drop):
    if not isinstance(keys_to_drop, list):
        keys_to_drop = [keys_to_drop]

    new_dct = {k: v for (k, v) in dct.items() if k not in keys_to_drop}

    return new_dct

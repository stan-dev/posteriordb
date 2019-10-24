import collections

import pytest


def _ensure_all_distinct(dct, error_message_callable):
    reverse_mapping = collections.defaultdict(list)
    for key, val in dct.items():
        reverse_mapping[val].append(key)

    duplicates = {k: v for (k, v) in reverse_mapping.items() if len(v) > 1}

    if len(duplicates) > 0:
        error_msgs = "\n".join(
            [
                error_message_callable(duplicate_val, duplicate_names)
                for (duplicate_val, duplicate_names) in duplicates.items()
            ]
        )
        pytest.fail(error_msgs)


def ensure_model_codes_are_distinct(dct):
    def error_msg(code_path, names):
        return f"""Models {", ".join(names)} had the same stan code: {code_path}"""

    __tracebackhide__ = True

    _ensure_all_distinct(dct, error_msg)


def ensure_dataset_paths_are_distinct(dct):
    def error_msg(data_file_path, names):
        return (
            f"""Datasets {", ".join(names)} had the same data file: {data_file_path}"""
        )

    __tracebackhide__ = True

    _ensure_all_distinct(dct, error_msg)

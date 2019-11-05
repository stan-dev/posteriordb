import json
import os
from pathlib import Path


def load_json_file(filepath):
    with open(filepath) as f:
        return json.load(f)


def load_info(path, assertion_function):
    info = load_json_file(path)
    assertion_function(info)
    return info


def temporary_no_assertions(x):
    return x


def filename(path):
    """Given a full file path return just the filename without extension """
    # with_suffix is needed in case the file has multiple extensions
    return path.with_suffix("").stem


def filenames_in_dir_no_extension(directory, extension):
    path = Path(directory)

    filenames = [filename(p) for p in path.glob("*" + extension)]
    return filenames


class PosteriorDatabase:
    def __init__(self, path: str):
        self.path = path
        # TODO assert that path is a valid posterior database

    def posterior(self, name):
        # inline import needed to avoid import loop
        from .posterior import Posterior

        return Posterior(name, self)

    def model(self, name):
        # inline import needed to avoid import loop
        from .model import Model

        return Model(name, self)

    def data(self, name):
        # inline import needed to avoid import loop
        from .dataset import Dataset

        return Dataset(name, self)

    def posterior_info_path(self, name: str):
        file_path = os.path.join(self.path, "posteriors", name + ".json")
        return file_path

    def get_posterior_info(self, name: str):
        file_path = self.posterior_info_path(name)
        return load_info(file_path, temporary_no_assertions)

    def get_model_info(self, name: str):
        # load from the correct path
        file_name = name + ".info.json"
        file_path = os.path.join(self.path, "models", "info", file_name)

        return load_info(file_path, temporary_no_assertions)

    def get_data_info(self, name: str):
        file_name = name + ".info.json"
        file_path = os.path.join(self.path, "data", "info", file_name)

        return load_info(file_path, temporary_no_assertions)

    def get_model_code_path(self, name, framework):
        model_info = self.get_model_info(name)
        path_within_posterior_db = model_info["model_code"][framework]
        full_path = os.path.join(self.path, path_within_posterior_db)
        return full_path

    def get_dataset_path(self, name):
        data_info = self.get_data_info(name)
        path = os.path.join(self.path, data_info["data_file"] + ".zip")
        return path

    def posterior_names(self):
        directory = os.path.join(self.path, "posteriors")
        # walk directory, find json files
        # strip file extension
        return filenames_in_dir_no_extension(directory, ".json")

    def model_names(self):
        directory = os.path.join(self.path, "models", "info")
        return filenames_in_dir_no_extension(directory, ".info.json")

    def dataset_names(self):
        directory = os.path.join(self.path, "data", "info")
        return filenames_in_dir_no_extension(directory, ".info.json")

    def posteriors(self):
        names = self.posterior_names()
        # inline import needed to avoid import loop
        from .posterior import Posterior

        for name in names:
            yield Posterior(name, self)

    def models(self):
        names = self.model_names()
        # inline import needed to avoid import loop
        from .model import Model

        for name in names:
            yield Model(name, self)

    def datasets(self):
        names = self.dataset_names()
        # inline import needed to avoid import loop
        from .dataset import Dataset

        for name in names:
            yield Dataset(name, self)

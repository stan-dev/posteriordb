import json
from functools import partial

from .dataset import Dataset
from .model_implementation_base import ModelImplementationBase


class PyStan2ModelImplementation(ModelImplementationBase):
    def __init__(self, posterior_db, *, model_code):
        self.posterior_db = posterior_db
        self.model_code = model_code

    def load(self, **kwargs):
        try:
            import pystan
        except ImportError:
            raise ValueError("`pystan` needs to be installed")
        model_code_file = self.posterior_db.full_path(self.model_code)
        stan_model = pystan.StanModel(file=model_code_file, **kwargs)
        return stan_model


class PyStanModelImplementation(ModelImplementationBase):
    def __init__(self, posterior_db, *, model_code, data=None):
        self.posterior_db = posterior_db
        self.model_code = model_code
        self.data = data

    def load(self, **kwargs):
        try:
            import stan
        except ImportError:
            raise ValueError("`pystan` needs to be installed")
        model_code_file = self.posterior_db.full_path(self.model_code)
        with open(model_code_file, "r") as file_obj:
            model_code = file_obj.read()
        try:
            if self.data is None and "data" in kwargs:
                kwargs = kwargs.copy()
                data = kwargs.pop("data")
            if isinstance(self.data, Dataset):
                data = self.data.values()
            elif not isinstance(self.data, dict):
                with open(self.data, "w") as file_obj:
                    data = json.load(file_obj)
        except ValueError as exc:
            raise ValueError("invalid data format, use dict or path to json.") from exc
        stan_model = stan.build(model_code, data)
        return stan_model


class CmdStanPyModelImplementation(ModelImplementationBase):
    def __init__(self, posterior_db, *, model_code):
        self.posterior_db = posterior_db
        self.model_code = model_code

    def load(self, **kwargs):
        try:
            from cmdstanpy import CmdStanModel
        except ImportError:
            raise ValueError("`cmdstanpy` needs to be installed")
        model_code_file = self.posterior_db.full_path(self.model_code)
        stan_model = CmdStanModel(stan_file=model_code_file, **kwargs)
        return stan_model

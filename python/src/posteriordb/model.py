import os
from typing import Any, Union

from . import STAN_BACKEND
from .posterior_database import PosteriorDatabase
from .posterior_database_github import PosteriorDatabaseGithub
from .pymc3_model_implementation import PyMC3ModelImplementation
from .stan_model_implementation import (
    PyStanModelImplementation,
    PyStan2ModelImplementation,
    CmdStanPyModelImplementation,
)
from .util import drop_keys

implementations = {
    "cmdstanpy": CmdStanPyModelImplementation,
    "pystan2": PyStan2ModelImplementation,
    "pystan": PyStanModelImplementation,
    "pymc3": PyMC3ModelImplementation,
}


class Model:
    def __init__(
        self,
        name: str,
        posterior_db: Union[PosteriorDatabase, PosteriorDatabaseGithub],
        data: Any = None,
    ):
        self.name = name
        self.posterior_db = posterior_db
        self._data = data
        full_model_info = self.posterior_db.get_model_info(name=self.name)
        self.information = drop_keys(full_model_info, "model_implementations")
        self._implementations = full_model_info["model_implementations"]

    def code_file_path(self, framework: str):
        """
        Returns filepath to model code file for `framework`
        """
        # TODO assert that framework is a valid framework for this model
        return self.posterior_db.get_model_code_path(self.name, framework)

    def code(self, framework: str):
        """
        Returns model code for `framework` as a string
        """
        file_path = self.code_file_path(framework)
        with open(file_path) as f:
            contents = f.read()

        return contents

    def stan_code(self):
        return self.code("stan")

    def stan_code_file_path(self):
        return self.code_file_path("stan")

    def implementation(self, framework, backend=None):
        if framework == "stan":
            if backend not in {"cmdstanpy", "pystan", "pystan2", None}:
                raise TypeError("Invalid backend option: {}".format(backend))
            if backend is None:
                backend = STAN_BACKEND

        implementation_info = self._implementations[framework]
        implementation_class = implementations[
            framework if backend is None else backend
        ]
        if framework == "stan" and backend == "pystan":
            implementation_obj = implementation_class(
                self.posterior_db, data=self._data, **implementation_info
            )
        else:
            implementation_obj = implementation_class(
                self.posterior_db, **implementation_info
            )
        return implementation_obj

import os

from .posterior_database import PosteriorDatabase
from .pymc3_model_implementation import PyMC3ModelImplementation
from .stan_model_implementation import StanModelImplementation
from .util import drop_keys

implementations = {"stan": StanModelImplementation, "pymc3": PyMC3ModelImplementation}


class Model:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name
        self.posterior_db = posterior_db
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

    def implementation(self, framework):
        implementation_info = self._implementations[framework]
        implementation_class = implementations[framework]
        implementation_obj = implementation_class(
            self.posterior_db, **implementation_info
        )
        return implementation_obj

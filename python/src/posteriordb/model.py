import os

from .posterior_database import PosteriorDatabase


class Model:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name
        self.posterior_db = posterior_db

    def model_code_file_path(self, framework: str):
        """
        Returns filepath to model code file for `framework`
        """
        # TODO assert that framework is a valid framework for this model
        return self.posterior_db.get_model_code_path(self.name, framework)

    def model_code(self, framework: str):
        """
        Returns model code for `framework` as a string
        """
        file_path = self.model_code_file_path(framework)
        with open(file_path) as f:
            contents = f.read()

        return contents

    def stan_code(self):
        return self.model_code("stan")

    def stan_code_file_path(self):
        return self.model_code_file_path("stan")

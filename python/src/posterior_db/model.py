import os

from .posterior_database import PosteriorDatabase


class Model:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name
        self.model_info = posterior_db.get_model_info(self.name)
        self.posterior_db = posterior_db

    def model_code_file_path(self, framework: str):
        """
        Returns filepath to model code file for `framework`
        """
        # TODO assert that framework is a valid framework for this model
        base_path = self.posterior_db.path
        path_within_posterior_db = self.model_info["model_code"][framework]
        full_path = os.path.join(base_path, path_within_posterior_db)
        return full_path

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

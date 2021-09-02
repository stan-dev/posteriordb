import json
from typing import Union
from zipfile import ZipFile

from .dataset import Dataset
from .model import Model
from .posterior_database import PosteriorDatabase
from .posterior_database_github import PosteriorDatabaseGithub
from .util import drop_keys


class Posterior:
    def __init__(
        self, name: str, posterior_db: Union[PosteriorDatabase, PosteriorDatabaseGithub]
    ):
        self.name = name

        assert name in posterior_db.posterior_names()

        self.posterior_db = posterior_db

        self.posterior_info = posterior_db.get_posterior_info(name)

        self.data = Dataset(self.posterior_info["data_name"], posterior_db)

        self.model = Model(
            self.posterior_info["model_name"], posterior_db, data=self.data
        )

        self.information = drop_keys(
            self.posterior_info,
            ["name", "model_name", "data_name", "reference_posterior_name"],
        )

    def reference_draws_info(self):
        return self.posterior_db.get_reference_draws_info(self.name)

    def reference_draws_file_path(self):
        return self.posterior_db.get_reference_draws_path(self.name)

    def reference_draws(self):
        reference_name = self.reference_draws_info()["name"]
        with ZipFile(self.reference_draws_file_path() + ".zip", "r") as z:
            with z.open(reference_name + ".json", "r") as f:
                return json.load(f)

from .dataset import Dataset
from .model import Model
from .posterior_database import PosteriorDatabase, load_json_file
from .util import drop_keys
from zipfile import ZipFile
import json


class Posterior:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name

        assert name in posterior_db.posterior_names()

        self.posterior_db = posterior_db

        self.posterior_info = posterior_db.get_posterior_info(name)

        self.model = Model(self.posterior_info["model_name"], posterior_db)

        self.data = Dataset(self.posterior_info["data_name"], posterior_db)

        self.information = drop_keys(
            self.posterior_info,
            ["name", "model_name", "data_name", "reference_posterior_name"],
        )

    def gold_standard_info(self):
        return self.posterior_db.get_gold_standard_info(self.name)
    
    def gold_standard_file_path(self):
        return self.posterior_db.get_gold_standard_path(self.name)
        
    def gold_standard(self):
        gold_standard_name = self.gold_standard_info()["name"]
        with ZipFile(self.gold_standard_file_path() + '.zip', 'r') as z:
            with z.open(gold_standard_name + '.json', 'r') as f:
                return json.load(f)
        

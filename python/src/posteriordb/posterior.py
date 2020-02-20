from .dataset import Dataset
from .model import Model
from .posterior_database import PosteriorDatabase
from .util import drop_keys


class Posterior:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name

        assert name in posterior_db.posterior_names()

        self.posterior_info = posterior_db.get_posterior_info(name)

        self.model = Model(self.posterior_info["model_name"], posterior_db)

        self.data = Dataset(self.posterior_info["data_name"], posterior_db)

        self.information = drop_keys(
            self.posterior_info,
            ["name", "model_name", "data_name", "reference_posterior_name"],
        )

    def gold_standard(self):
        # gold_standard_file = self.posterior_info["gold_standard"]
        raise NotImplementedError()
        # need to unzip gold standard

    def gold_standard_file_path(self):
        # gold_standard = self.gold_standard()
        # make tempfile and put gold standard there
        raise NotImplementedError()

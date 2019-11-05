from .dataset import Dataset
from .model import Model
from .posterior_database import PosteriorDatabase


class Posterior:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name

        assert name in posterior_db.posterior_names()

        self.posterior_info = posterior_db.get_posterior_info(name)

        self.model = Model(self.posterior_info["model_name"], posterior_db)

        self.data = Dataset(self.posterior_info["data_name"], posterior_db)

    def model_code_file_path(self, framework: str):
        return self.model.code_file_path(framework)

    def stan_code_file_path(self):
        return self.model.stan_code_file_path()

    def stan_code(self):
        return self.model.stan_code()

    def model_code(self, framework: str):
        return self.model.code(framework)

    def data_values(self):
        return self.data.values()

    def data_file_path(self):
        return self.data.file_path()

    def gold_standard(self):
        # gold_standard_file = self.posterior_info["gold_standard"]
        raise NotImplementedError()
        # need to unzip gold standard

    def gold_standard_file_path(self):
        # gold_standard = self.gold_standard()
        # make tempfile and put gold standard there
        raise NotImplementedError()

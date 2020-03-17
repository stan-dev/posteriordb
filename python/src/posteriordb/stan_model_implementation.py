from .model_implementation_base import ModelImplementationBase


class StanModelImplementation(ModelImplementationBase):
    def __init__(self, posterior_db, *, model_code):
        self.posterior_db = posterior_db
        self.model_code = model_code

    def load(self):
        try:
            import pystan
        except ImportError:
            raise ValueError("`pystan` needs to be installed")
        model_code_file = self.posterior_db.full_path(self.model_code)
        stan_model = pystan.StanModel(file=model_code_file)
        return stan_model

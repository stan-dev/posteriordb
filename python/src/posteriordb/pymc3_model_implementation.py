import os
import sys

from .model_implementation_base import ModelImplementationBase


class add_path:
    def __init__(self, path):
        self.path = path

    def __enter__(self):
        sys.path.insert(0, self.path)

    def __exit__(self, exc_type, exc_value, traceback):
        try:
            sys.path.remove(self.path)
        except ValueError:
            pass


class PyMC3ModelImplementation(ModelImplementationBase):
    def __init__(self, posterior_db, *, model_code):
        self.posterior_db = posterior_db
        self.model_code = model_code

    def load(self):
        try:
            import pymc3
        except ImportError:
            raise ValueError("pymc3 needs to be installed")
        import importlib

        model_code_file = self.posterior_db.full_path(self.model_code)
        model_code_directory = os.path.dirname(model_code_file)
        with add_path(model_code_directory):
            model_code_module_name, _ = os.path.splitext(os.path.basename(model_code_file))
            module = importlib.import_module(model_code_module_name)

        return module.model

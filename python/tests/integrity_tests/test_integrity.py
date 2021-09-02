import os

from posteriordb import PosteriorDatabase

from . import helpers


def get_posterior_db():
    project_path = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    )
    pdb_path = os.path.join(project_path, "posterior_database")
    pdb = PosteriorDatabase(pdb_path)
    assert len(pdb.posterior_names()) > 0
    return pdb


def test_models_dont_have_same_model_code():
    pdb = get_posterior_db()

    model_code_paths = {
        model.name: model.stan_code_file_path() for model in pdb.models()
    }

    helpers.ensure_model_codes_are_distinct(model_code_paths)


def test_datasets_dont_have_same_data():
    pdb = get_posterior_db()

    data_names = pdb.dataset_names()

    data_file_paths = {name: pdb.get_dataset_path(name) for name in data_names}

    helpers.ensure_dataset_paths_are_distinct(data_file_paths)

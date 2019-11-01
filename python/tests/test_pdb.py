import os

from posteriordb import Posterior
from posteriordb import PosteriorDatabase


def test_posterior_database():
    # path to ../../ which is the posterior database directory
    project_path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    pdb_path = os.path.join(project_path, "posterior_database")
    pdb = PosteriorDatabase(pdb_path)

    model_names = pdb.model_names()
    assert len(model_names) > 0

    dataset_names = pdb.dataset_names()
    assert len(dataset_names) > 0

    posterior_names = pdb.posterior_names()

    assert len(posterior_names) > 0

    for name in posterior_names:
        posterior = Posterior(name, pdb)

        assert posterior.dataset() is not None
        assert posterior.dataset_file_path() is not None
        assert posterior.model_code("stan") is not None
        assert posterior.model_code_file_path("stan") is not None
        assert posterior.stan_code() is not None
        assert posterior.stan_code_file_path() is not None
        assert posterior.model.stan_code_file_path() is not None
        assert posterior.model_info is not None
        assert posterior.data_info is not None

    posteriors = list(pdb.posteriors())
    assert len(posteriors) > 0

    models = list(pdb.models())
    assert len(models) > 0

    datasets = list(pdb.datasets())
    assert len(datasets) > 0

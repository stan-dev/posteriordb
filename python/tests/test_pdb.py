import os
import re

from posteriordb import PosteriorDatabase, PosteriorDatabaseGithub


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
        posterior = pdb.posterior(name)

        assert posterior.name is not None

        # test dataset methods
        data = posterior.data
        assert data.name is not None

        assert data.values() is not None
        assert data.file_path() is not None

        assert data.information is not None

        # test that pdb.data works
        data2 = pdb.data(data.name)
        assert data2 is not None

        # test model methods
        model = posterior.model

        assert model.name is not None

        assert model.code("stan") is not None
        assert model.code_file_path("stan") is not None
        assert model.stan_code() is not None
        assert model.stan_code_file_path() is not None

        assert model.information is not None

        # test that pdb.model works
        model2 = pdb.model(model.name)
        assert model2 is not None

    posteriors = list(pdb.posteriors())
    assert len(posteriors) > 0

    models = list(pdb.models())
    assert len(models) > 0

    datasets = list(pdb.datasets())
    assert len(datasets) > 0


def test_posterior_database_github():
    # Skip test if GITHUB_PAT not defined
    if os.environ.get("GITHUB_PAT") is None:
        return

    kwargs = {}
    if os.environ.get("GITHUB_ACTIONS"):
        kwargs["repo"] = os.environ.get("GITHUB_REPOSITORY", "MansMeg/posteriordb")
        kwargs["ref"] = re.sub(
            "^refs/heads/", "", os.environ.get("GITHUB_REF", "master")
        )
    pdb = PosteriorDatabaseGithub(**kwargs)

    model_names = pdb.model_names()
    assert len(model_names) > 0

    dataset_names = pdb.dataset_names()
    assert len(dataset_names) > 0

    posterior_names = pdb.posterior_names()

    assert len(posterior_names) > 0

    for name in posterior_names:
        posterior = pdb.posterior(name)

        assert posterior.name is not None

        # test dataset methods
        data = posterior.data
        assert data.name is not None

        assert data.values() is not None
        assert data.file_path() is not None

        assert data.information is not None

        # test that pdb.data works
        data2 = pdb.data(data.name)
        assert data2 is not None

        # test model methods
        model = posterior.model

        assert model.name is not None

        assert model.code("stan") is not None
        assert model.code_file_path("stan") is not None
        assert model.stan_code() is not None
        assert model.stan_code_file_path() is not None

        assert model.information is not None

        # test that pdb.model works
        model2 = pdb.model(model.name)
        assert model2 is not None

    posteriors = list(pdb.posteriors())
    assert len(posteriors) > 0

    models = list(pdb.models())
    assert len(models) > 0

    datasets = list(pdb.datasets())
    assert len(datasets) > 0

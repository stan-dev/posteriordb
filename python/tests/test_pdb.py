import os

from posteriordb import Posterior
from posteriordb import PosteriorDatabase


def test_posterior_database():
    # path to ../../ which is the posterior database directory
    path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    pdb = PosteriorDatabase(path)

    posterior_names = pdb.posterior_names()

    assert len(posterior_names) > 0

    for name in posterior_names:
        posterior = Posterior(name, pdb)

        assert posterior.dataset() is not None
        assert posterior.model_code("stan") is not None

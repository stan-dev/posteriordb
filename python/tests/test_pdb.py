import os

from posterior_db import Posterior
from posterior_db import PosteriorDatabase


def test_posterior_database():
    # path to ../.. which is the posterior database directory
    path = os.path.dirname(os.path.dirname(__file__))
    pdb = PosteriorDatabase(path)  # needs to get parent directory I think

    posterior_names = pdb.posterior_names()

    for name in posterior_names:
        posterior = Posterior(name, pdb)

        assert posterior.data()
        assert posterior.model_code("stan")

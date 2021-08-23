from .posterior_database import PosteriorDatabase
from .posterior_database_github import PosteriorDatabaseGithub

__version__ = "0.2.0"

STAN_BACKEND = "cmdstanpy"


def change_stan_backend(backend):
    assert backend in {"cmdstanpy", "pystan", "pystan2"}
    global STAN_BACKEND
    STAN_BACKEND = backend

Contributing
===========

Pull request workflow
-------------

1. Fork this repository and clone your fork locally
1. Install pre-commit (see **Installing pre-commit** below)
1. Make changes and commit them
1. Run tests (see **Tests**)
1. Push to your fork
1. Open a pull request in GitHub

Installing pre-commit
--------------

[pre-commit](https://pre-commit.com/) helps catch style issues early so
reviewing PRs can focus on more meaningful parts of the PR.

Install it with
```bash
python3 -m pip install --user pre-commit
```
Your system needs to have Python 3.6 or higher.

Check that it works correctly

```
pre-commit run --all-files
```

Install pre-commit hooks

```bash
pre-commit install
```

Now pre-commit hooks get run when you `git commit`. For example if a file
that you are committing has trailing whitespace `pre-commit` will remove
the trailing whitespace, abort the commit and let you stage the modifications.
Then you can run `git commit` again.

All the checks are also run by continuous integration when you make a pull request.
This means that you don't necessarily have to use `pre-commit` locally.
However we suggest using it locally as that gives more immediate feedback.


Tests
-----------

See python and R test sections

### Python tests


1. Install `tox`: `pip install tox`
1. Run
   ```bash
   tox
   ```
   This automatically configures several python versions and runs the tests on each of them.
   **NOTE**: python 3.6 and python 3.7 need to be installed.

   It is also fine to run on just one python version if for example you don't have
   all the versions installed locally. (as continuous integration will cover
   running on all versions)
   ```bash
   tox -e py36, linting
   ```
   This runs the tests on python3.6 and also runs the linting step.

### R tests
TODO

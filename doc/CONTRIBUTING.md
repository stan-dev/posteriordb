Contributing
===========

We are happy for you to contribute with new posteriors to the datasbase. just create a Pull Request with you new content to the posteriordb, the tests on the new content will be checked.

Below are checklists depending on the what you want to contribute.

CONTENT CHECKLISTS
-------------

Below are checklists to contributing parts to

### Add a posterior - CHECKLIST

1. Use the json file for eight_schools at `posteriors/eight_schools-eight_schools_centered.json` as a template. See
1. Save the posterior as `[data_name]-[model_name].json` in `posteriors`
1. If new data or new model code is needed, this should be added at the same time.
1. Add a new gold standard for the new posterior (see below)

### Add new data - CHECKLIST

1. Create an R or python script to generate data as a ziped json file following the format of the posterior data, store the script and the raw data in `data/data-raw/` with the name `[data_name].[r/py]`.
1. Save the ziped json data in `data/data-raw/`
1. Use the json info for eight_schools at `data/info/eight_schools.info.json` as a template and create an information file on the new data.
1. If you added a new reference, also add the reference in the references file (see below).

### Add new model - CHECKLIST

1. Save the model file in `models/[framework]/[model_name].[file extension]` (as an example `models/stan/eight_schools_centered.stan`)
1. Use the json info for eight_schools at `models/info/eight_schools_centered.info.json` as a template and create an information file on the new model.
1. If you are adding a totally new framework, create an issue and we see how we can add this.
1. If you added a new reference, also add the reference in the references file (see below).

### Add new gold standard - CHECKLIST

To see what qualifies as a gold standard, see GOLD_STANDARD_DEFINITION.md.

1. Save the gold standard file in `gold_standard/[posterior_name].json.zip`. See DATABASE_CONTENT.md on how the gold_standard JSON file.


### Add new reference - CHECKLIST

1. Add the reference to the `references/reference.bib` BiBTeX file.






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

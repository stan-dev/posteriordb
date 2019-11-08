Contributing
============

We are happy for you to contribute with new posteriors to the datasbase. just create a Pull Request with you new content to the posteriordb, the tests on the new content will be checked.

Don't hesitate to do a Pull Request (PR) with a new model, data or posterior to the repository. We use the PR for discussion on new material!

Pull request workflow
-------------

1. Fork this repository
1. Make a contribution
1. Open a pull request in GitHub (the tests will the automatically run on Travis)


CONTENT CHECKLISTS
-------------

Below are checklists to contributing to the posterior database.

### Add a posterior - CHECKLIST

1. Use the json file for eight_schools at `posteriors/eight_schools-eight_schools_centered.json` as a template and mody the file to your posterior.
1. Save the posterior as `[data_name]-[model_name].json` in `posteriors/`
1. If new data or new model code is needed, added this (see below).
1. Add a new gold standard for the new posterior (see below)
1. If you added a new reference, also add the reference in the references file (see below).

### Add new data - CHECKLIST

1. Create an R or python script to generate data as a ziped json file following the format of the posterior data, store the script and the raw data in `data/data-raw/` with the name `[data_name].[r/py]`.
1. Save the ziped json data file in `data/data-raw/[data_name].json.zip`
1. Use the json info for eight_schools at `data/info/eight_schools.info.json` as a template and create an information file on the new data.
1. If you added a new reference, also add the reference in the references file (see below).

### Add new model - CHECKLIST

If you are adding a totally new framework, create an issue and we see how we can add this in the best way.

1. Save the model file in `models/[framework]/[model_name].[file extension]` (as an example `models/stan/eight_schools_centered.stan`)
1. Use the json info for eight_schools at `models/info/eight_schools_centered.info.json` as a template and create an information file on the new model.
1. If you added a new reference, also add the reference in the references file (see below).


### Add new gold standard - CHECKLIST

To see what qualifies as a gold standard, see [GOLD_STANDARD_DEFINITION.md](https://github.com/MansMeg/posteriordb/blob/master/doc/GOLD_STANDARD_DEFINITION.md).

1. Save the gold standard information in `gold_standard/info/[posterior_name].info.json`. See [DATABSE_CONTENT.md](https://github.com/MansMeg/posteriordb/blob/master/doc/DATABASE_CONTENT.md) on how the gold_standard JSON file should be structured.
1. Save the gold standard draws in `gold_standard/draws/[posterior_name].json.zip`. See [DATABSE_CONTENT.md](https://github.com/MansMeg/posteriordb/blob/master/doc/DATABASE_CONTENT.md) on how the gold_standard JSON file with draws should be structured.


### Add new reference - CHECKLIST

1. Add the reference to the `references/reference.bib` BiBTeX file.


Pre-commit and Tests
====================

Below are more details on how to run pre-commits for code cleaning and
tests to test your contribution locally before opening up a PR.

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

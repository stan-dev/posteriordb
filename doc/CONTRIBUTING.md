Contributing
============

We are happy for you to contribute with code or new posteriors to the database. Create a Pull Request (PR) with your new content to the posteriordb; the content will be checked using Github Actions.

Don't hesitate to make a PR with a new model, data, or posterior to the repository. We use the PR for discussion on new material!

Copyright
-------------
All models supplied will use the BSD3 license by default. Specifying an alternative open-source license for data, model or reference posterior object is possible.


Pull request workflow
-------------

1. Fork this repository and clone the repository
1. Contribute and add data/models/posteriors to the local (cloned) posteriordb
1. Commit the contribution and push to your fork
1. Open a pull request (the tests of the contribution will automatically run on Github Action)


CONTRIBUTING CONTENT
-------------

There are currently two ways to contribute content to the posterior database: (1) Adding new content directly, (2) Adding content using R and the `posteriordb` R package.

It is currently simpler to add new content through R, but hopefully, we will simplify other approaches further on.


## Add content directly

It is possible to add content directly to the database by manually specifying the JSON objects. A simple approach is to use the `eight_schools-eight_schools_noncentered` posterior,the `eight_schools_noncentered` model, and the `eight_schools` data as a template to start out from.

The exact content of each information file can be found in [doc/DATABASE_CONTENT.md](https://github.com/stan-dev/posteriordb/blob/master/doc/DATABASE_CONTENT.md).

## Add content through R

You can find an extensive vignette detailing how to add content from R [here](https://htmlpreview.github.io/?https://github.com/stan-dev/posteriordb-r/blob/main/vignettes/contributing.html).


import os
import re
from setuptools import setup

PROJECT_ROOT = os.path.dirname(os.path.realpath(__file__))
VERSION_FILE = os.path.join(PROJECT_ROOT, "src", "posteriordb", "__init__.py")


def get_version():
    lines = open(VERSION_FILE, "rt").readlines()
    version_regex = r"^__version__ = ['\"]([^'\"]*)['\"]"
    for line in lines:
        mo = re.search(version_regex, line, re.M)
        if mo:
            return mo.group(1)
    raise RuntimeError("Unable to find version in %s." % (VERSION_FILE,))


setup(
    name="posteriordb",
    version=get_version(),
    description="python interface to posterior database",
    url="https://github.com/MansMeg/posteriordb",
    author="Eero Linna",
    author_email="eero.linna@aalto.fi",
    license="GPL",
    packages=["posteriordb"],
    package_dir={"": "src"},
    zip_safe=False,
)

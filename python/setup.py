from setuptools import setup

setup(
    name="posterior_db",
    version="0.1",
    description="python interface to posterior database",
    url="https://github.com/MansMeg/posteriordb",
    author="Eero Linna",
    author_email="eero.linna@aalto.fi",
    license="GPL",
    packages=["posterior_db"],
    package_dir={"": "src"},
    zip_safe=False,
)

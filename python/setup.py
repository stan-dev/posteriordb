from setuptools import setup

setup(
    name="posteriordb",
    version="0.1",
    description="python interface to posterior database",
    url="https://github.com/MansMeg/posteriordb",
    author="Eero Linna",
    author_email="eero.linna@aalto.fi",
    license="GPL",
    packages=["posteriordb"],
    package_dir={"": "src"},
    zip_safe=False,
)

import json
import os
import tempfile
from zipfile import ZipFile

from .posterior_database import PosteriorDatabase


class Dataset:
    def __init__(self, name: str, posterior_db: PosteriorDatabase):
        self.name = name
        self.posterior_db = posterior_db

        self.data_info = posterior_db.get_data_info(self.name)

    def dataset_file_path(self):
        data = self.dataset()
        # make a temp file with unzipped data
        with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
            json.dump(data, f)
            file_name = f.name
        return file_name

    def dataset(self):
        # unzip the file on the fly
        # return contents
        path = os.path.join(
            self.posterior_db.path, self.data_info["data_file"] + ".zip"
        )
        archive_file_name = os.path.basename(self.data_info["data_file"])
        with ZipFile(path) as zipfile:
            with zipfile.open(archive_file_name) as f:
                data = json.load(f)
        return data

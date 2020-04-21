from abc import ABC
from abc import abstractmethod


class ModelImplementationBase(ABC):
    @abstractmethod
    def load(self):
        pass

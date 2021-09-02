from abc import ABC, abstractmethod


class ModelImplementationBase(ABC):
    @abstractmethod
    def load(self):
        pass

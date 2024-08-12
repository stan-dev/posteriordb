## Sampling PyMC models

Steps to sample PyMC models: 

1. load the model json data from the respctive zipfile as a Python dictionary. 

For example, for the GLM binomial model:

```python
import json
import zipfile

# Load zipfile
zfile = zipfile.ZipFile(r"posterior_database/data/data/GLM_Binomial_data.json.zip", 'r')
data = json.loads(zfile.read("GLM_Binomial_data.json"))
```

2. Call the model defining function, with the data dictionary and, in a `with` context, call `pm.sample`:

```python
import pymc as pm

from posterior_database.models.pymc.GLM_Binomial_model import model

# Call the function that creates the PyMC model and sample it
with model(data):
    trace = pm.sample()

print(pm.stats.summary(trace))
```

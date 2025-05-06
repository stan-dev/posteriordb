
import pymc as pm
import pandas as pd
from zipfile import ZipFile
import json 

# Load data
zip_file = ZipFile('posterior_database/data/data/earnings.json.zip', 'r')
data = json.loads(zip_file.read('earnings.json'))
N = data.pop('N')
df = pd.DataFrame(data)

sampler_config = {
    "chains": 10,
    "draws": 2000,
    "tune": 1000,
    "random_seed": 8675309,
}


# Define PyMC Model
coords = {
    'obs_idx': df.index,
    'feature': ['intercept', 'height']
}

with pm.Model(coords=coords) as earn_height:
    earn = pm.Data('earn', df['earn'], dims=['obs_idx'])
    height = pm.Data('height', df['height'], dims=['obs_idx'])
    
    beta = pm.Flat('beta', dims=['feature'])
    mu = beta[0] + beta[1] * height
    
    sigma = pm.HalfFlat('sigma')
    earn_hat = pm.Normal('earn_hat', mu=mu, sigma=sigma, observed=earn, dims=['obs_idx'])

    idata = pm.sample(**sampler_config)

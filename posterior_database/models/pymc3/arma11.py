import pymc as pm
import pytensor
import pytensor.tensor as pt
def model(data):
    y_obs = data["y"]  # Observed series
    up_to = data["T"]  # Timesteps
    with pm.Model() as pymc_model:
        mu = pm.Normal(
            "mu", mu=0, sigma=10
        )  # mean coefficient
        phi = pm.Normal(
            "phi", mu=0, sigma=2
        ) # autoregressive coef
        theta = pm.Normal(
            "theta", mu=0, sigma=2
        ) # moving average
        sigma = pm.Cauchy(
            "sigma", alpha=0, beta=2.5
        ) # noise scale

        # scan variables
        i = pt.arange(up_to)
        outputs_info = [pt.as_tensor_variable(np.asarray(0.0)), pt.as_tensor_variable(np.asarray(0.0))]

        def step(prev_obs, current_obs, seq, _, prev_error, mu, phi, theta):
            y_hat = pt.switch(pt.gt(seq, 0), mu + phi * prev_obs + theta * prev_error, mu + phi * mu)
            return [y_hat, current_obs - y_hat]
        
        [predictions, _], _ = pytensor.scan(fn=step,
                                            outputs_info=outputs_info,
                                            sequences=[{"input": pt.as_tensor_variable(y_obs), "taps": [-1, 0]}, i],
                                            non_sequences=[mu, phi, theta])

        final_predictions = predictions[-1]
        pm.Normal("output", mu=final_predictions, sigma=sigma, observed=y_obs)
      
    return pymc_model
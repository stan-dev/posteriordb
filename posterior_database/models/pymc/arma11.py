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
        sigma = pm.HalfCauchy(
            "sigma", beta=2.5
        ) # noise scale

        # scan variables
        y = pt.as_tensor_variable(y_obs)
        y_hat0 = mu + phi * mu
        err0 = y[0] - y_hat0
        outputs_info = [y_hat0, err0, y[0]]

        def step(curr_obs, prev_pred, prev_err, prev_obs, mu, phi, theta):
            y_hat = mu + phi * prev_obs + theta * prev_err
            new_err = curr_obs - y_hat
            return [y_hat, new_err, curr_obs]

        [predictions, _, _] , _ = pytensor.scan(fn=step,
                                              outputs_info=outputs_info,    
                                              sequences=y[1:],              
                                              non_sequences=[mu, phi, theta])

        # concatenating predictions
        y_hat0_vec = y_hat0.dimshuffle("x")
        final_predictions = pt.concatenate([y_hat0_vec, predictions])

        pm.Normal("y", mu=final_predictions, sigma=sigma, observed=y)

    return pymc_model
data {
    int<lower=1> nEvent;                 // number of events
    int<lower=1> nObs;                   // number of observations
    array[nObs] int<lower=1> iObs;       // index of events which are observations

    // Event schedule
    array[nEvent] int<lower=1> cmt;
    array[nEvent] int evid;
    array[nEvent] int addl;
    array[nEvent] int ss;
    array[nEvent] real amt;
    array[nEvent] real time;
    array[nEvent] real rate;
    array[nEvent] real ii;

    // observed drug concentration
    vector<lower=0>[nObs] cObs;
}

transformed data {
    int nCmt = 3;
    int nTheta = 5;
}

parameters {
    real<lower=0> CL;
    real<lower=0> Q;
    real<lower=0> VC;
    real<lower=0> VP;
    real<lower=0> ka;
    real<lower=0> sigma;
}

transformed parameters {
    array[nTheta] real theta = {CL, Q, VC, VP, ka};
    row_vector<lower=0>[nEvent] concentrationHat;
    matrix<lower=0>[nCmt, nEvent] mass;
    mass = pmx_solve_twocpt(time, amt, rate, ii, evid, cmt, addl, ss, theta);

    // Extract mass in central compartment and divide by central volume
    concentrationHat = mass[2, ] ./ VC;
}

model {
    // priors
    CL    ~ lognormal(log(10),  0.25);
    Q     ~ lognormal(log(15),  0.5);
    VC    ~ lognormal(log(35),  0.25);
    VP    ~ lognormal(log(105), 0.5);
    ka    ~ lognormal(log(2.5), 1);
    sigma ~ normal(0, 1);

    // likelihood
    cObs ~ lognormal(log(concentrationHat[iObs]), sigma);
}

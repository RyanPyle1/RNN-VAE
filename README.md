# RNN-VAE
Hybrid prediction system. Use VAE to get latent states of a time-dependent system. Use RNN (Reservoir Computer) to evolve latents. 
VAE translates to predictions.

Based on synthetic data, generated via MATLAB

VAE based off an existing pythong jupyter implementation.

RNN updates via MATLAB. 



To Run:

Run Generate.m. This will get synthetic data. 

Ensure the data is placed under root='../../data/synth', or modify the path in the python notebook.

Run VAE.ipynb, first section. This will generate model parameters, including latent variables.

load logvarout.csv, muout.csv into matlab, or ensure it is in the same folder as the RNNClimateVae.m file

Run RNNClimateVAE.m. This will generate predictions on the latent variables. Performance may vary per run.
If performance is good, run the final code block in the if(false) area to save predictions

Run VAE.ipynb, second section. This will generate output predictions from the latent predictions.

VAE.ipynb also has two additional sections for further analysis.
The third section varies one latent direction while keeping the others constant, allowing to see how each latent variable changes final output.
The fourth section looks at the relative performance 'cost' of moving in each direction in latent space from a fixed point, based on https://arxiv.org/pdf/1710.11379.pdf


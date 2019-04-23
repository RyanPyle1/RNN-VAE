Shows results of the prediction and analysis. 

predicted(1-3).png show the next 150 time steps of predictions, arranged in sheets.
Predicted.gif combines them into a moving .gif

varyl(1-3)mini.png shows the effects of varying a single latent dimension by a small amount, e.g. derivative at that point.

varyl(1-3).png show the effects of a wider range of variations. 

samples/reconst-(1-25) shows VAE reconstruction quality during training over 25 epochs.

samples/sampled-(1-25) shows VAE sample quality during training over 25 epochs.


Overall, VAE performance was good. Final outcome predictions were ok - it succesfully learned 'climate' rules, e.g. moving in approximately a straight line and bouncing off walls. However, it would occasionally forget its direction, and sometimes 'morph' position. The morphing appears to be an issue with the latent space, as varying latents causes a similar effect.




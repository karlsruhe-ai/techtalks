# Neural Network Design and Wasserstein Loss

**17. November 2017**

We focus your attention on how most machine learning algorithms perceive the
problems they try to solve: the loss function that describes how good the model
represents the observations. Analogy time! You are lost in the middle of an N
dimensional sea with no GPS on a cloudy night with no moon. Luckily you have a
compass. If the boat is your model, then the loss function is your compass. And
you better have a good one.

We will analyze a few problems whose solution depends on using the right loss
function. Of the loss functions used, we will highlight the Wasserstein Loss.
Although the Wasserstein metric is the natural distance when it comes to
comparing distributions, it has seen limited use because its calculation was
computationally expensive. This limitation has been partially lifted recently.
Now it is feasible to use the Wasserstein Loss to train Deep Neural Networks.
Despite some impressive results, some difficulties remain to make Wasserstein
Loss widely applicable.

The talk is held by Manuel Martinez Torres. Manuel recently defended his PhD
thesis about automated monitoring of sleep at the CV:HCI lab at KIT.

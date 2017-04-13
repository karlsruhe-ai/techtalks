# Julius Pfrommer: Introduction to Probabilistic Graphical Models

**12. April 2017**

Probabilistic Graphical Models (PGM) are a powerful tool for representing complex probability distributions and efficient inference. For this, PGM exploit (conditional) statistical independence in the model. This talk introduces the core ideas and algorithms of PGM from first principles. Examples are provided based on an implementation of PGM in ~100 lines of Python (no external libraries used).

The provided library comes in two parts:

- gdl.py: Implementation of the main algorithms on general algebraic semirings (Generalized Distributive Law)
- cpt.py: Small wrapper around gdl.py to perform probabilistic inference with Conditional Probabiliy Tables (CPT)
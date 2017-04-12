# Conditional Probability Tables
# by Julius Pfrommer, 2017

import gdl
import operator

# Semiring for computing with discrete probabilities
addmul = gdl.CommutativeSemiRing(operator.add, 0, operator.mul, operator.truediv, 1)

class Variable(gdl.Variable):
    pass

class CPT(gdl.Factor):
    "Conditional Probability Table"
    def __init__(self, table, domain):
        self.table = table
        self.domain = domain

    def __call__(self, *args):
        running_cardinality = 1
        pos = 0
        for var, val in reversed(list(enumerate(args))):
            var_domain = self.domain[var].var_domain
            pos += running_cardinality * var_domain.index(val)
            running_cardinality *= len(var_domain)
        return self.table[pos]

def marginalize(f, retain):
    return gdl.marginalize(addmul, f, retain)

def join(f1, f2):
    return gdl.join(addmul, f1, f2)

def normalize(f, kappa=None):
    return gdl.normalize(addmul, f, kappa)

def eliminate(f, var, value):
    return normalize(gdl.eliminate(f, var, value))

class FactorGraph(gdl.FactorGraph):
    def __init__(self, variables, factors):
        super(FactorGraph, self).__init__(addmul, variables, factors)

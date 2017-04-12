# Generalized Distributive Law Operations
# by Julius Pfrommer, 2017

from itertools import compress, product as iter_product

class CommutativeSemiRing(object):
    def __init__(self, add, zero, mul, invmul, one):
        self.add = add
        self.zero = zero
        self.mul = mul
        self.invmul = invmul # optional, only required for normalization
        self.one = one

class Variable(object):
    def __init__(self, name, var_domain):
        self.name = name
        self.var_domain = var_domain

    def __repr__(self):
        return "Variable(\"%s\", %s)" % (self.name, str(self.var_domain))

class Factor(object):
    def __init__(self, f, domain):
        self.f = f
        self.domain = domain

    def __call__(self, *args):
        return self.f(*args)

    def __repr__(self):
        table = [( ("(" + ", ".join([x.name for x in self.domain]) + ")", "value") )]
        for args in iter_product(*[var.var_domain for var in self.domain]):
            table.append( (str(args), str(self(*args))) )
        arg_len = max([len(x[0]) for x in table])
        val_len = max([len(x[1]) for x in table])
        s = [table[0][0].ljust(arg_len) + " " + table[0][1]]
        s.append(("-" * arg_len) + " " + ("-" * val_len))
        for i in range(1,len(table)):
            s.append(table[i][0].ljust(arg_len) + " " + table[i][1])
        return '\n'.join(s)

def marginalize(ring, f, retain):
    "Marginalize according to the addition operator of the ring."
    bitmask = [var.name in retain for var in f.domain]
    results = {}
    for args in iter_product(*[var.var_domain for var in f.domain]):
        reduced_args = tuple(compress(args,bitmask))
        if reduced_args in results:
            results[reduced_args] = ring.add(results[reduced_args], f(*args))
        else:
            results[reduced_args] = f(*args)
    def marginalized(*args):
        return results[args]
    return Factor(marginalized, [var for var in f.domain if var.name in retain])

def join(ring, f1, f2):
    "Join two factors using the ring's multiplication operator."
    f1_names = [var.name for var in f1.domain]
    new_domain = f1.domain + [var for var in f2.domain if var.name not in f1_names]
    new_names = [var.name for var in new_domain]
    arg_pos2 = [new_names.index(var.name) for var in f2.domain]
    results = {}
    for args in iter_product(*[var.var_domain for var in new_domain]):
        args1 = args[:len(f1_names)]
        args2 = [args[x] for x in arg_pos2]
        results[args] = ring.mul(f1(*args1), f2(*args2))
    def merged(*args):
        return results[args]
    return Factor(merged, new_domain)

def normalize(ring, f, kappa=None):
    "If kappa is not set, normalize by the sum of values in the domain."
    if kappa == None:
        kappa = ring.zero
        for args in iter_product(*[var.var_domain for var in f.domain]):
            kappa = ring.add(kappa, f(*args))
    def normalized(*args):
        return ring.invmul(f(*args), kappa)
    return Factor(normalized, f.domain)

def eliminate(f, var, value):
    "Set one of the factor variables to a fixed value."
    reduced_domain = [v for v in f.domain if v.name != var]
    if len(reduced_domain) == len(f.domain):
        return f
    varindex = [v.name for v in f.domain].index(var)
    def reduced(*args):
        return f(*(args[:varindex] + (value,) + args[varindex:]))
    return Factor(reduced, reduced_domain)

class FactorGraph(object):
    def __init__(self, ring, variables, factors):
        self.ring = ring
        self.variables = variables
        self.factors = factors

        self.neighbours = dict([[x, []] for x in self.variables + self.factors])
        for f in self.factors:
            for v in f.domain:
                self.neighbours[f].append(v)
                self.neighbours[v].append(f)
        self.messages = {}

    def message(self, source, target):
        m = None
        domain = None
        if isinstance(source, Variable):
            def unity(*arg):
                return self.ring.one
            m = Factor(unity, [source])
            domain = source.name
        else:
            m = source
            domain = target.name
        # Join received messages (and the factor), excluding messages from the target
        m = reduce(lambda x,y: join(self.ring, x, y),
                   [self.messages[(n, source)] for n in self.neighbours[source] if n != target], m)
        m = marginalize(self.ring, m, [domain]) # Marginalize the message to the domain of the variable
        self.messages[(source, target)] = m # "Send"

    def posterior(self, variable):
        "Evaluate a node with the given arguments"
        def unity(*arg):
            return self.ring.one
        m = Factor(unity, [variable])
        for n in self.neighbours[variable]:
            m = join(self.ring, m, self.messages[(n, variable)])
        return normalize(self.ring, m)

    def forward_backward_pass(self):
        "On a tree-graph, send all messages until convergence"
        while True:
            finished = True
            for i in self.variables + self.factors:
                for j in self.neighbours[i]:
                    if (i,j) in self.messages:
                        continue
                    can_send = True
                    for j2 in self.neighbours[i]:
                        if j2 == j:
                            continue
                        if (j2,i) not in self.messages:
                            can_send = False
                            break
                    if can_send:
                        self.message(i,j)
                        finished = False
            if finished:
                break

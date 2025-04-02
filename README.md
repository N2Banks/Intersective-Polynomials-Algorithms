# Intersective-Polynomial-Algorithms

This is a collection of algorithms for checking *intersectivity* of a polynomial. This was developed for my PhD thesis in the pure math department at the University of Waterloo, Ontario, Canada. Some more about me and my academic career on my [personal site](https://sites.google.com/view/nicbanks/home).

A polynomial $P(x)\in\mathbb{Z}[x]$ is called **intersective** if it has a root modulo $n$ for every positive integer $n$. Of course, any root in $\mathbb{Z}$ itself descends to a root in each of these quotients, so the interesting ones are those with no integer roots. These are called **strongly intersective**.

Some examples are $(x^3-19)(x^2+x+1)$ (annoying to check by hand) and $(x^2-2)(x^2-17)(x^2-34)$ (straightforward to check with Legendre symbols).

Note that having a root modulo all n is equivalent to having a root in the $p$-adic numbers $\mathbb{Q}_p$ for all primes $p$. Thus, one can expect the primes dividing the discriminant of $P(x)$ to behave differently - a common story in number theory.

One important paper on this subject was by Berend and Bilu ("Polynomials with Roots Modulo Every Integer", 1996) which provided a number-theoretic algorithm to check intersectivity. The arithmetic half of the algorithm amounts to finding roots modulo certain prime powers (primes dividing the polynomial discriminant, with powers large enough so that Hensel's Lemma takes over). The second, algebraic half is checking if the polynomial's Galois group over $\mathbb{Q}$ can be covered by conjugates of certain subgroups.

The Galois-theoretic algorithm is implemented in GAP, since the small group library is easier to use (it is present in SageMath, but slightly more awkard to work with). This is the content of **file 1**.

One can show that strongly intersective polynomials are always reducible and of degree $\geq 5$. Therefore, it is useful to note that, if $P$ factors into irreducibles as $P(x)=h_1(x)\cdots h_r(x)$ and $h_i$ has Galois group $G_i$ over $\mathbb{Q}$, then the Galois group $G$ of $P$ over $\mathbb{Q}$ is a subgroup of the direct product $G_1\times\cdots\times G_r$. In fact, it is a subdirect product, which means that the restrictions of the projection maps to $G$ are all surjective. Equivalently, $G$ has a family of normal subgroups $N_1,\cdots,N_r$ such that $G/N_i\cong G_i$ and $\bigcap_{i=1}^{r}N_i$ is the trivial subgroup. In particular, this means that $|G|$ is divisible by $\mathrm{lcm}(|G_1|,\cdots,|G_r|)$.

Therefore, to classify possible Galois groups of strongly intersective polynomials by degree, it is helpful to have a list of all subdirect products of possible direct products of Galois groups. This was implemented in SageMath and is the content of **file 2**.

For the arithmetic side of things, it was simpler to use a theorem of Sonn ("Polynomials With Roots in $\mathbb{Q}_p$ For All $p$", 2008) involving decomposition groups. As part of my thesis, I showed that this condition need only hold for ramified primes, and since these are finite in number, this constitutes another algorithm. This is the content of **file 3**.

In my thesis, I also proved another criteria for intersectivity at ramified primes. It amounts to checking ramification and inertia degrees in various subextensions cut out by single roots. This is the content of **file 4**.
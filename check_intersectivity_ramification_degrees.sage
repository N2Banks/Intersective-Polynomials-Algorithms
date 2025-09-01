# Checks whether the product of distinct, irreducible polynomials h_1*h_2*...*h_r is intersective at ramified primes. In other words, this checks if h_1*...*h_r has a root in the p-adics Q_p for all primes p which divide the discriminant
    # f is an irreducible polynomial defining the same splitting field as h_1*...*h_r. f can be found using resultants, c.f. Awtrey et al. Magma also has a built-in method; the following returns a possible choice for f:

    # P<x> := PolynomialAlgebra(Rationals());
    # f := (x^5-2*x^4+7*x^3-4*x^2+11*x+6)*(x^4-x^3+13*x^2-19*x+361);
    # K<a> := SplittingField(f); K;

    # This method is based on a result from my thesis: Instead of finding polynomial roots, we check if there is an i such that the ramified prime p has a prime factor with inertia and ramification degree both equal to 1 in some intermediate extension defined by a root of h_i

# Inputs:
        # f: The defining polynomial of the number field K (computed with Magma)
        # polynomials: List of polynomials whose roots define subfields K_i

    # Returns:
        # A message indicating whether the polynomial is intersective at ramified primes, and if not, at which primes the failure occurs

def check_intersectivity_ramification_degrees(f, *polynomials):
    x = polygen(QQ)
    K = NumberField(f, 'a')
    a = K.gen()
    
    # I've thought about implementing the "lmfdbMapping" list and "group_identifier" function from the "find_subdirect_products.sage" file in this repo. It would be useful but the return on investment is definitely lower here than the aforementioned file.

    G = K.galois_group()
    # print(f"Galois Group: {G.structure_description()}")

    # Find discriminant and ramified primes
    disc_K = K.discriminant()
    # print(f"Discriminant of K: {disc_K}")
    ramified_primes = disc_K.support()
    # print(f"Ramified primes: {ramified_primes}\n")

    # Define one subfield K_i for each factor h_i via a fixed root
    K_subfields = []
    for poly in polynomials:
        theta = poly.roots(ring=QQbar, multiplicities=False)[0]
        K_subfields.append(NumberField(poly, f'theta_{len(K_subfields)+1}'))
    
    # For prettier / more informative output string
    poly_product_str = "*".join(f"({poly})" for poly in polynomials)

    # For each ramified prime p, check if it has a prime with the correct ramification and inertia degrees lying above it in one of the K_i
    for p in ramified_primes:
        # print(f"Checking prime {p}...")
        
        found_valid_prime = False
        for i, K_i in enumerate(K_subfields):
            prime_ideals = factor(K_i.ideal(p))
            for ideal, exp in prime_ideals:
                f_p = ideal.residue_field().degree()
                e_p = ideal.ramification_index()
                if f_p == 1 and e_p == 1:
                    found_valid_prime = True
                    # print(f"  Found suitable prime in K_{i+1}: {ideal}")
                    break
            if found_valid_prime:
                break
        
        if not found_valid_prime:
            return f"The polynomial {poly_product_str} is not intersective; it fails at the ramified prime {p}."
    
    return f"The polynomial {poly_product_str} is intersective at ramified primes."

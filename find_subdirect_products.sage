# Let D := G_1 x ... x G_r be a direct product of finite groups. A subgroup G of D is called a "subdirect product" if the restricted projection maps pi_i: G -> G_i are all surjective
# Equivalently, and easier to check on a computer: G is a subdirect product of G as an abstract group if it has a set of normal subgroups N_1, ..., N_r such that G/N_i is isomorphic to G_i, and the N_i all intersect trivially
# This comes up in Galois theory: If P(x) = h_1(x)*...*h_r(x) is the factorization of P into irreducibles (over, say, the rationals Q), let G be the Galois group of P and G_i the Galois group of h_i. Then G is a subdirect product of G_1 x ... x G_r (see Lang's "Algebra" for a proof)
# In particular, the order |G| must be divisible by |G_i| for each i. In other words, |G| is divisible by lcm(|G_1|, ..., |G_r|). More particularly, if the |G_i| are coprime, then G_1 x ... x G_r has no proper subdirect products

# I became interested in these groups while working on my thesis. My goal was to classify all possible Galois groups of "strongly intersective polynomials" (see the "README.md" of this repository on GitHub)
# To this end, I wanted to find all subdirect products of various products of Galois groups

# The logic is as follows:
    # Form the direct product iteratively, e.g., if r = 2 then D := G_1.direct_product(G_2)[0]. Note that this GAP-based function returns a tuple, with the group itself being the first entry, hence the list index
    # Iterate over proper subgroups H of D whose order is divisible by L := lcm(|G_1|, ..., |G_r|)
    # For each H from above, check if H has a quotient isomorphic to G_i for each i (actually, we only need to check for G_i of different isomorphism types, which is the number "k". This saves some time but probably not much)
        # Important note - finding the unique isomorphism types among the G_i assumes that groups are sorted by the user in the input. For example, if r = 3 and both G_1 and G_2 are C_2, make sure to define the input list as "groups = [CyclicPermutationGroup(2), CyclicPermutationGroup(2), AlternatingGroup(4)]" and NOT as "[CyclicPermutationGroup(2), AlternatingGroup(4), CyclicPermutationGroup(2)]"
    # If H has such a family of normal subgroups, then we check if they have trivial intersection
    # To catch positive results early, we do this in blocks: If N_1 and N_2 already intersect trivially, and H has the appropriate other quotients, then we already can conclude positively about H
    # Naturally, this means negative results will take longest to find
    # Since I only cared about them up to isomorphism, once a subdirect product is found, all candidate subgroups which are isomorphic are skipped. However, this cannot be done for negative results, as subdirectness can depend on the exact copy of the subgroup that appears
    # Since subgroups are sorted by order, if there is an issue with higher order subgroups (e.g., finding their group IDs), we can still print the results up to that point. An error message will then be shown indicating at which order the problem occurred


# Inputs:
    # A list of finite groups [G_1, ..., G_r], aptly named "groups"
# Outputs:
    # The number of non-isomorphic subdirect products of G_1 x ... x G_r, along with their GAP SmallGroup IDs, called as "group_id()"

# There are many commented lines which form a progress report. This is good for debugging, and also helps put one's mind at ease during long computations

# ===============================================

import itertools

lmfdbMapping = {
    PermutationGroup([[(2,3,5,7,6,4), (9,10,11)], [(1,2,4,5), (3,6,7,8), (9,10)]]): "2016.cw",
    PermutationGroup([[(1,3,5,7), (4,6), (8,9), (10,11)], [(1,2,4,3), (5,6), (9,10,11)]]): "2016.cx",
    PermutationGroup([[(1,2,4,6,5,3), (7,8,9)], [(1,3), (2,5,4)]]): "2160.bz",
    PermutationGroup([[(1,2,3,4,6), (7,9,8)], [(1,2,3,4,5), (7,8)]]): "2160.ca",
    PermutationGroup([[(1,2,4,5,6,3), (7,8)], [(2,3,4), (7,8,9)]]): "2160.cb",
    PermutationGroup([[(2,4), (6,7,10), (8,11,9)], [(1,2), (3,5,4), (6,8,10,9,7,11)], [(1,3,2,4), (6,9,7,8,10,11)]]): "2160.ce",
    PermutationGroup([[(1,2,4,5,3), (7,8,9)], [(1,3,5), (2,4), (6,7), (8,10,9,11)]]): "2160.cg",
    PermutationGroup([[(1,2,3,5), (6,8,9,11,7,10)], [(1,3,2,4,5), (6,7,9), (8,11,10)], [(1,2), (3,4), (7,9), (8,10)]]): "2160.ch",
    PermutationGroup([[(1,3,4,5), (6,8), (7,9), (10,11)], [(1,2,3,4), (6,7), (9,10)], [(1,2,4,5,3), (6,9), (7,8), (10,11)]]): "2160.ci",
    PermutationGroup([[(1,2,3,4,5), (6,8), (7,9,11,10)], [(2,3), (4,5), (6,7), (9,10)]]): "2160.cj",
    PermutationGroup([[(1,2,3,4,5), (6,8,9,7,10,11)], [(2,3), (4,5), (6,7,9,8,10,11)]]): "2160.cm",
    PermutationGroup([[(1,2,3), (4,5,6), (7,8,9), (10,11)], [(2,3,4,5,6), (10,11)]]): "2160.cn",
    PermutationGroup([[(1,2,4,5,3), (6,7,8), (9,10,11)], [(1,3,4,2), (7,8), (9,11)], [(1,2,4,5,3), (6,8), (9,11)]]): "2160.ct",
    PermutationGroup([[(1,2), (3,5), (4,6), (7,8), (9,10)], [(1,3,6,7,2,5), (4,8)], [(1,2), (5,7), (9,10)], [(1,4), (2,6), (3,5), (9,10)], [(3,7,5)]]): "2304.ea",
    PermutationGroup([[(3,7), (6,8), (10,11)], [(2,6,7), (3,4,8)], [(1,2,5,4), (6,8)], [(3,7)], [(2,4), (3,7), (9,10,11)], [(1,3), (2,6), (4,8), (5,7)]]): "2304.ey",
    PermutationGroup([[(1,2), (3,4,5), (7,8,9,10)], [(2,3,4,5), (6,7), (8,9)]]): "2400.db",
    PermutationGroup([[(3,4,5,6,7)], [(1,2,3)]]): "2520.a",
    PermutationGroup([[(1,3,4,7,8,6), (2,5,9), (10,11)], [(1,2,4,7,3,5), (6,9,8)], [(2,5), (3,6), (4,8), (7,9)]]): "2592.cg",
    PermutationGroup([[(1,4,7), (2,3,6)], [(1,2), (3,4), (5,8), (6,7), (9,10)], [(1,3), (2,4), (5,8), (6,7)], [(1,3,2,5,4,7,6)]]): "2688.cd",
    PermutationGroup([[(1,2,3,4,5), (6,8), (7,9), (10,11)], [(1,2,4,6), (7,10), (8,9)], [(2,3,5), (7,8), (9,10)]]): "2880.du",
    PermutationGroup([[(2,3,4), (6,7,9,8)], [(1,2,3,5), (6,8)]]): "2880.dv",
    PermutationGroup([[(1,2), (3,4,5,6), (8,9)], [(1,2,3,4,5), (7,8), (9,10)]]): "2880.dx",
    PermutationGroup([[(1,2,3,5), (4,6), (7,8), (9,10)], [(1,3,6,2,4,5), (7,9)]]): "2880.ea",
    PermutationGroup([[(1,2,4,3,5,6), (7,8), (9,10)], [(1,3,2,4,6), (7,9,8,10)]]): "2880.eb",
    PermutationGroup([[(1,3,5,6,2,4), (8,10)], [(1,2), (3,5), (7,8,9,10)]]): "2880.ec",
    PermutationGroup([[(1,2,3,4), (7,8), (10,11)], [(2,3), (6,7), (9,10)], [(1,2,3), (4,5), (6,8,9,11)]]): "2880.eg",
    PermutationGroup([[(1,2,3,4,5), (7,8)], [(1,3,5,2), (6,7,9,11,8,10)]]): "2880.eh",
    PermutationGroup([[(1,2,3), (6,8), (7,10), (9,11)], [(2,4), (3,5), (6,7), (8,10), (9,11)], [(1,2), (3,5), (6,7,9,10,8,11)]]): "2880.ei",
    PermutationGroup([[(1,2), (4,5,6,7,9,8), (10,11)], [(1,3,2,4,6,8), (7,9)]]): "3024.r",
    PermutationGroup([[(1,2,4,7,6,8), (3,5), (9,10)], [(1,3,6,4), (5,7,8), (10,11)]]): "3456.cy",
    PermutationGroup([[(1,3,5,6,8,2,4,7), (9,10)], [(1,2), (3,5), (4,6), (7,8), (10,11)]]): "3456.cz",
    PermutationGroup([[(1,3,6,7), (2,4), (5,8), (9,10)], [(1,2), (3,5,4,7), (6,8), (10,11)]]): "3456.da",
    PermutationGroup([[(1,2), (3,5), (4,7,6,8), (9,11,10)], [(2,3,4,6), (9,10,11)]]): "3456.db",
    PermutationGroup([[(1,3), (2,5), (4,6), (7,8)], [(10,11)], [(2,4), (6,7)], [(1,2,4)], [(9,10)]]): "3456.di",
    PermutationGroup([[(1,2), (4,5,7), (6,8), (10,11)], [(1,3), (2,4,6,5), (7,8), (9,10,11)]]): "3456.dj",
    PermutationGroup([[(1,3), (2,4), (6,8,10,7,9)], [(1,2,3,5,4), (6,7), (8,9)]]): "3600.a",
    PermutationGroup([[(1,2,4,6,5), (7,8), (9,10)], [(1,3,5,6,4), (8,9), (10,11)]]): "3600.ce",
    PermutationGroup([[(1,2,4,6), (3,5), (7,8,9,10,11)], [(1,3,2), (5,6), (7,9), (10,11)]]): "3600.ch",
    PermutationGroup([[(1,2), (3,5,6), (7,8,10,11,9)], [(1,3), (2,4), (5,6), (7,9,11,10,8)]]): "3600.cl",
    PermutationGroup([[(1,2), (3,4), (5,6), (7,8), (9,10,11)], [(1,3,5,4,6,7,2), (9,10,11)]]): "4032.cj",
    PermutationGroup([[(1,3), (6,7), (10,11)], [(1,2,4,6), (3,5), (8,9,10)]]): "4032.cl",
    PermutationGroup([[(1,3,5,4,6,2), (8,9)], [(1,2,5,3,6), (7,8)], [(1,4,2,6), (3,5), (7,8,9)]]): "4320.bg",
    PermutationGroup([[(1,2,4), (3,5,6), (8,9,10)], [(1,3,2,4), (5,6), (7,8,10)]]): "4320.bh",
    PermutationGroup([[(1,3), (2,5), (4,6), (7,9,8,10,11)], [(1,2,4), (5,6), (7,8), (9,11)]]): "4320.bi",
    PermutationGroup([[(2,3), (4,5), (6,7)], [(1,2), (3,4,5), (6,8), (7,9,10,11)]]): "4320.bk",
    PermutationGroup([[(1,4,2), (6,8,7,10), (9,11)], [(1,3,4), (2,5), (8,11,10)], [(1,2,5,4,3), (6,7,9)]]): "4320.bl",
    PermutationGroup([[(1,3), (2,5), (6,8,11,10,7,9)], [(1,4,3,2,5), (6,8,7,10,11,9)], [(1,2), (3,4,5), (6,7), (9,10)]]): "4320.bp",
    PermutationGroup([[(2,3,5,4), (8,10)], [(1,2), (3,4,5), (6,7,8,9,10,11)]]): "4320.br",
    PermutationGroup([[(1,2), (3,4,5), (7,8,9), (10,11)], [(2,3,4,6,5), (7,8,9), (10,11)]]): "4320.bt",
    PermutationGroup([[(1,3), (2,4,5,6), (7,8,9), (10,11)], [(1,2), (5,6), (8,9)]]): "4320.bu",
    PermutationGroup([[(1,2,4,6,5,3), (7,8), (10,11)], [(1,3,2,5,4,6), (8,9)]]): "4320.bv",
    PermutationGroup([[(1,3,5)], [(8,9)], [(1,2,4,6,5,7,3)]]): "5040.v",
    PermutationGroup([[(1,2,3,4,5,6,7)], [(1,2)]]): "5040.w",
    PermutationGroup([[(1,2), (3,4), (5,6)], [(7,8)], [(1,3), (4,5,6), (7,9), (8,10)]]): "5760.ch",
    PermutationGroup([[(1,4,2), (3,5), (6,9,10), (7,11,8)], [(1,3,2,5,4), (6,8), (7,10,9,11)], [(1,2), (3,5,4), (6,7), (8,9), (10,11)]]): "5760.co",
    PermutationGroup([[(1,3), (2,6,4,5), (7,8), (10,11)], [(1,2,4), (3,6), (10,11)], [(1,3,7,6,2,5,4,8), (9,10,11)]]): "6912.br",
    PermutationGroup([[(1,2), (3,4,5), (7,9,10)], [(1,2,3), (6,7,8,9,10)]]): "7200.br",
    PermutationGroup([[(1,2,3,5), (4,6), (8,10,11,9)], [(3,4,6), (7,8,9,10)]]): "7200.ce",
    PermutationGroup([[(2,4), (3,5), (7,9), (10,11)], [(1,2,3,5,6,4), (7,8,9,10,11)]]): "7200.cg",
    PermutationGroup([[(1,2,3), (4,5), (8,9,11,10)], [(2,3,4,6,5), (7,8,10,9,11)]]): "7200.ck",
    PermutationGroup([[(1,2,3,4,5), (6,7,9)], [(2,4,5,3), (6,8,10,7)], [(1,2,4), (6,8,7,10,9)]]): "7200.d",
    PermutationGroup([[(1,2,4,6,7,5,3), (8,9,10)], [(1,3,2,5), (6,7), (8,9,10)]]): "7560.e",
    PermutationGroup([[(1,3,4,6,5,8,7), (9,11)], [(1,2), (4,5,7,8), (9,10)]]): "8064.bp",
    PermutationGroup([[(1,2,4), (5,6), (7,9), (8,10)], [(2,3,4,5), (7,8,9)]]): "8640.n",
    PermutationGroup([[(1,2), (3,4,5), (7,8)], [(1,2,3,4,6), (8,9,10)]]): "8640.o",
    PermutationGroup([[(1,2,3,4), (5,6), (7,8,10)], [(2,4,5,6,3), (7,9,10,8)]]): "8640.p",
    PermutationGroup([[(1,2,4,3,5), (6,7,9,8,10,11)], [(1,3), (2,4,5), (6,7,10,8), (9,11)], [(1,3,4,2,5), (6,8,10,11), (7,9)]]): "8640.r",
    PermutationGroup([[(1,2,3,5,6,4), (7,9), (10,11)], [(2,4,3), (7,8)], [(1,3,6), (2,5), (7,8,9)]]): "8640.t",
    PermutationGroup([[(3,4)], [(8,9)], [(1,2,3,4,5,6,7)]]): "10080.l",
    PermutationGroup([[(1,2,4), (3,5,6,7), (8,9,10,11)], [(1,3,2,5,6), (8,10), (9,11)]]): "10080.m",
    PermutationGroup([[(1,3,4,6,5,7,2), (8,10), (9,11)], [(1,2,4,5,7), (8,9), (10,11)]]): "10080.n",
    PermutationGroup([[(1,2,4,7,6,3,5), (8,9,10,11)], [(2,3,5), (4,6,7)]]): "10080.o",
    PermutationGroup([[(1,3,5), (2,4), (6,7), (8,9,10)], [(1,2,4), (7,9,10,8)], [(1,2,4), (6,8,9), (7,10)]]): "14400.bg",
    PermutationGroup([[(1,3,4,5), (8,9), (10,11)], [(1,2,3), (5,6), (7,8,9,10)]]): "14400.bj",
    PermutationGroup([[(1,2,4,5), (3,6,7), (8,9,10)], [(1,3,2,5,7,4)]]): "15120.d",
    PermutationGroup([[(1,2,4,6,5), (8,9,10)], [(1,3,2,5), (4,7), (9,10)]]): "15120.e",
    PermutationGroup([[(1,2,4,3,5), (8,9,10)], [(1,3,5,7), (2,4,6), (9,10)]]): "15120.f",
    PermutationGroup([[(1,2), (3,4,5,6,7,8)], [(1,2,3)]]): "20160.a",
    PermutationGroup([[(1,3,6), (4,7), (8,10,11,9)], [(1,2,4), (3,5), (6,7), (8,9), (10,11)]]): "20160.i",
    PermutationGroup([[(1,2,3,4,5,6,7), (8,9)], [(1,2,3,5,7,6,4), (8,10), (9,11)]]): "20160.j",
    PermutationGroup([[(2,3,5,4), (8,9,10,11)], [(1,2), (3,4,6), (5,7), (8,9,10,11)]]): "20160.k",
    PermutationGroup([[(1,2,4,6), (8,9), (10,11)], [(1,3,2,5,4), (8,10), (9,11)], [(1,3,6,4,5,7,2), (8,11), (9,10)]]): "20160.l",
    PermutationGroup([[(1,2,3,4), (5,6,7), (8,9)], [(2,3,5,6,7,4), (8,10), (9,11)]]): "20160.m",
    PermutationGroup([[(1,2,3,4,5), (7,8,10,11,9)], [(4,5,6), (7,8,9,11,10)]]): "21600.o",
    PermutationGroup([[(1,3,6,4,7,2,5), (8,9,10)], [(1,2,4,5), (3,6), (9,10,11)]]): "30240.c",
    PermutationGroup([[(1,2,3,4,5,6,7,8)], [(1,2)]]): "40320.a",
    PermutationGroup([[(1,2), (3,4,6,5,7,8)], [(1,3,5,7), (6,8), (9,10)]]): "40320.i",
    PermutationGroup([[(1,3,2,5,4,6,7), (8,10,11,9)], [(1,2,4,7), (3,6,5), (8,9), (10,11)], [(1,3,5,6,2,4), (8,9,11,10)]]): "40320.k",
    PermutationGroup([[(1,3), (2,4), (7,8,9,10)], [(1,2), (3,5,4,6), (8,10,11)], [(2,3,4,6,5), (7,9), (8,10)]]): "43200.m",
    PermutationGroup([[(1,2,4,5,3,6), (7,8,9,10,11)], [(1,3,2,5,4), (9,11,10)]]): "43200.n",
    PermutationGroup([[(1,3,5), (2,4), (7,9,11), (8,10)], [(1,2), (3,5,4,6), (7,8), (9,10)]]): "43200.p",
    PermutationGroup([[(1,3,6,8,4,2,5), (9,11,10)], [(1,2,4), (3,6,5,7,8), (9,10,11)]]): "60480.c",
    PermutationGroup([[(1,2,3,4,6), (5,7), (8,10,11)], [(3,4,5,6,7), (8,9,11)]]): "60480.d",
    PermutationGroup([[(1,3), (2,5,4,7,6), (8,10,9,11)], [(1,2,4,7), (3,6), (8,9,10)]]): "60480.e",
    PermutationGroup([[(1,3), (2,4,7), (5,6), (8,9,10)], [(1,2,3,5), (4,6), (10,11)]]): "60480.f",
    PermutationGroup([[(1,2,3,4,6), (7,8,9,10)], [(1,3,5,2), (7,8,9,11)]]): "86400.c",
    PermutationGroup([[(2,3,5,6,8), (4,7), (9,10,11)], [(1,2,4,3,6,8,7), (9,10,11)]]): "120960.b",
    PermutationGroup([[(1,3,6,5,8,7,2,4), (9,11)], [(1,2,4,6), (3,5,7,8), (9,10,11)]]): "120960.c",
    PermutationGroup([[(1,3,4,6,8), (2,5,7), (9,10,11)], [(1,2,4,3,5), (9,10)]]): "120960.d",
    PermutationGroup([[(1,3,4,6,5,2), (8,9,11,10)], [(1,2,4,5,7,6), (8,9,10)]]): "120960.e",
    PermutationGroup([[(2,3), (4,5,7,8), (9,10)], [(1,2,4,6,7,8,5,3), (9,11)]]): "241920.a",
    PermutationGroup([[(1,2)], [(1,2,3,4,5,6,7,8,9)]]): "362880.a",
    PermutationGroup([[(2,4,7), (3,5,8,9,6), (10,11)], [(1,2,3,4,6,8,7), (10,11)]]): "362880.b",
    PermutationGroup([[(1,2,4,8,5,9), (3,6,7)], [(1,3,7,4,8,2,5,9), (10,11)]]): "725760.a"
}

def find_subdirect_products(groups):
    
    if not groups:
        print("No groups provided.")
        return

    # Form the direct product D iteratively.
    if len(groups) == 1:
        D = groups[0]
    else:
        D = groups[0]
        for g in groups[1:]:
            D = D.direct_product(g)[0]

    print("Direct product D formed.")

    # Compute L := lcm(|G_1|, ..., |G_r|)
    orders = [G_i.order() for G_i in groups]
    L = lcm(orders)

    print("Computed lcm(|G_1|,...,|G_r|) =", L)

    # Determine the distinct group identifiers (as returned by groupIdentifier) and their counts.
    distinct_ids = []
    counts = []
    prev = None
    for G in groups:
        try:
            g_id = groupIdentifier(G)
        except Exception as e:
            print("Error computing group identifier for one of the input groups; aborting.")
            return
        if g_id != prev:
            distinct_ids.append(g_id)
            counts.append(1)
            prev = g_id
        else:
            counts[-1] += 1
    k = len(distinct_ids)

    print("Distinct group IDs:", distinct_ids)
    print("Counts for each distinct group:", counts)

    # Form the list S of all proper subgroups H of D whose order is divisible by L.
    S = [H for H in D.subgroups() if H != D and (H.order() % L == 0)]

    print("Found", len(S), "proper subgroups of D with orders divisible by", L)

    if len(S) == 0:
        print("No proper subgroups of D have order divisible by lcm(|G_1|,...,|G_r|) = {}.".format(L))
        return

    # Lists to store subdirect products and their representatives (for filtering by isomorphism)
    subdirect_reps = []
    subdirect_products = []
    
    # Flag and storage for error encountered during processing
    error_encountered = False
    error_order = None

    # Process each candidate subgroup H in S
    for j, H in enumerate(S):

        # Try to compute the group identifier for H for progress reporting.
        try:
            current_gid = groupIdentifier(H)
        except Exception as e:
            error_encountered = True
            error_order = H.order()
            print("Error encountered computing group identifier for subgroup with order {}. Stopping processing.".format(error_order))
            break

        print("\nProcessing subgroup {} of {}: group_id = {}, order = {}.".
        #       format(j+1, len(S), current_gid, H.order()))
        
        # Skip H if it is isomorphic to a previously found subdirect product.
        skip = False
        for rep in subdirect_reps:
            if H.is_isomorphic(rep):
                print("Skipping H since it is isomorphic to a previously found subdirect product (group_id {}, order {}).".format(groupIdentifier(rep), rep.order()))
                skip = True
                break
        if skip:
            continue

        # For H, form lists N[0],...,N[k-1]: H must have a quotient isomorphic to each input group.
        N = []
        valid_H = True
        for i in range(k):
            try:
                N_i = [N_sub for N_sub in H.normal_subgroups() 
                       if groupIdentifier(H.quotient(N_sub)) == distinct_ids[i]]
            except Exception as e:
                error_encountered = True
                error_order = H.order()
                print("Error encountered computing quotient group identifier for subgroup with order {}. Stopping processing.".format(error_order))
                valid_H = False
                break
            if len(N_i) == 0:
                print("No normal subgroup of H yields a quotient with group identifier", distinct_ids[i], "; skipping H.")
                valid_H = False
                break
            N.append(N_i)
        if error_encountered:
            break
        if not valid_H:
            continue

        trivial_found = False

        # Block 1: Form all intersections of exactly counts[0] (with repetition allowed) subgroups from N[0].
        B = []
        print("Processing block 1 for subgroup H...")
        for combo in itertools.product(N[0], repeat=counts[0]):
            inter = combo[0]
            for subgroup in combo[1:]:
                inter = inter.intersection(subgroup)
            if inter.order() == 1:
                trivial_found = True
                break
            B.append(inter)
        if trivial_found:
            print("Subgroup with group identifier {} (order {}) IS a subdirect product.".format(groupIdentifier(H), H.order()))
            subdirect_products.append(H)
            subdirect_reps.append(H)
            continue

        # Process subsequent blocks.
        for i in range(1, k):
            new_B = []
            print("Processing block", i+1, "for subgroup H...")
            for B_elem in B:
                for combo in itertools.product(N[i], repeat=counts[i]):
                    inter_temp = combo[0]
                    for subgroup in combo[1:]:
                        inter_temp = inter_temp.intersection(subgroup)
                    inter_final = B_elem.intersection(inter_temp)
                    if inter_final.order() == 1:
                        trivial_found = True
                        break
                    new_B.append(inter_final)
                if trivial_found:
                    break
            if trivial_found:
                print("Subgroup with group identifier {} (order {}) IS a subdirect product.".format(groupIdentifier(H), H.order()))
                subdirect_products.append(H)
                subdirect_reps.append(H)
                break
            B = new_B
        if error_encountered:
            break
        # if not trivial_found:
            print("Subgroup with group identifier {} (order {}) is NOT a subdirect product.".format(groupIdentifier(H), H.order()))

    # Summary output:
    print("\nSummary:")
    if subdirect_products:
        print("Found {} subdirect product(s):".format(len(subdirect_products)))
        for H in subdirect_products:
            print("  - subgroup with group identifier {} and order {}".format(groupIdentifier(H), H.order()))
    else:
        print("None of the proper subgroups of D (of order divisible by {}) is a subdirect product.".format(L))
    if error_encountered:
        print("Stopped processing at subgroup of order {} due to an error computing group identifiers.".format(error_order))

# ===============================================
# Example:
    # The below example may take some time, but should output 2 non-isormphic subdirect products, [720, 763] and [1440, 5842] (S_6 and C_2 x S_6)

# sage: G_1 = CyclicPermutationGroup(2)
# sage: G_2 = CyclicPermutationGroup(2)
# sage: G_3 = SymmetricGroup(6)
# sage: groups = [G_1, G_2, G_3]
# sage: find_subdirect_products(groups)
# ===============================================
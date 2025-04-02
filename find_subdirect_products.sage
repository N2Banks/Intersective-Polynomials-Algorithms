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

def find_subdirect_products(groups):
    
    if not groups:
        print("No groups provided.")
        return

    # Form the direct product D iteratively
    if len(groups) == 1:
        D = groups[0]
    else:
        D = groups[0]
        for g in groups[1:]:
            D = D.direct_product(g)[0]

    # print("Direct product D formed.")

    # Compute L := lcm(|G_1|, ..., |G_r|)
    orders = [G_i.order() for G_i in groups]
    L = lcm(orders)

    # print("Computed lcm(|G_1|,...,|G_r|) =", L)

    # Determine the distinct group IDs and their counts (assuming isomorphic groups appear consecutively)

    distinct_ids = []
    counts = []
    prev = None
    for G in groups:
        try:
            g_id = G.group_id()
        except Exception as e:
            print("Error computing group_id for one of the input groups; aborting.")
            return
        if g_id != prev:
            distinct_ids.append(g_id)
            counts.append(1)
            prev = g_id
        else:
            counts[-1] += 1
    k = len(distinct_ids)

    # print("Distinct group IDs:", distinct_ids)
    # print("Counts for each distinct group:", counts)

    # Form the list S of all proper subgroups H of D whose order is divisible by L

    S = [H for H in D.subgroups() if H != D and (H.order() % L == 0)]

    # print("Found", len(S), "proper subgroups of D with orders divisible by", L)

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

        # Try to compute H.group_id() for progress reporting.

        try:
            current_g_id = H.group_id()
        except Exception as e:
            error_encountered = True
            error_order = H.order()
            print("Error encountered computing group_id() for subgroup with order {}. Stopping processing.".format(error_order))
            break

        # print("\nProcessing subgroup {} of {}: group_id = {}, order = {}.".
              # format(j+1, len(S), current_gid, H.order()))
        
        # If H is isomorphic to a subdirect product we already found, skip it

        skip = False
        for rep in subdirect_reps:
            if H.is_isomorphic(rep):

                # print("Skipping H since it is isomorphic to a previously found subdirect product (group_id {}, order {}).".format(rep.group_id(), rep.order()))

                skip = True
                break
        if skip:
            continue

        # For H, form lists N[0],...,N[k-1]
        # H must have a quotient with each distinct group ID

        N = []
        valid_H = True
        for i in range(k):
            try:
                N_i = [N_sub for N_sub in H.normal_subgroups() 
                      if H.quotient(N_sub).group_id() == distinct_ids[i]]
            except Exception as e:
                error_encountered = True
                error_order = H.order()

                # print("Error encountered computing quotient group_id() for subgroup with order {}. Stopping processing.".format(error_order))

                valid_H = False
                break
            if len(N_i) == 0:

                # print("No normal subgroup of H yields a quotient with group_id", distinct_ids[i], "; skipping H.")

                valid_H = False
                break
            N.append(N_i)
        if error_encountered:
            break
        if not valid_H:
            continue

        trivial_found = False

        # Block 1: Form all intersections of exactly counts[0] (with repetition allowed) subgroups from N[0]

        B = []

        # print("Processing block 1 for subgroup H...")

        for combo in itertools.product(N[0], repeat=counts[0]):
            inter = combo[0]
            for subgroup in combo[1:]:
                inter = inter.intersection(subgroup)
            if inter.order() == 1:
                trivial_found = True
                break
            B.append(inter)
        if trivial_found:

            # print("Subgroup with group_id {} (order {}) IS a subdirect product.".format(H.group_id(), H.order()))
            subdirect_products.append(H)
            subdirect_reps.append(H)
            continue

        for i in range(1, k):
            new_B = []

            # print("Processing block", i+1, "for subgroup H...")

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

                # print("Subgroup with group_id {} (order {}) IS a subdirect product.".format(H.group_id(), H.order()))

                subdirect_products.append(H)
                subdirect_reps.append(H)
                break
            B = new_B
        if error_encountered:
            break
        # if not trivial_found:
            # print("Subgroup with group_id {} (order {}) is NOT a subdirect product.".format(H.group_id(), H.order()))

    # Summary output:
    print("\nSummary:")
    if subdirect_products:
        print("Found {} subdirect product(s):".format(len(subdirect_products)))
        for H in subdirect_products:
            print("  - subgroup with group_id {} and order {}".format(H.group_id(), H.order()))
    else:
        print("None of the proper subgroups of D (of order divisible by {}) is a subdirect product.".format(L))
    if error_encountered:
        print("Stopped processing at subgroup of order {} due to an error computing group_id().".format(error_order))

# ===============================================
# Example:
    # The below example may take some time, but should output 2 non-isormphic subdirect products, [720, 763] and [1440, 5842] (S_6 and C_2 x S_6)

# sage: G_1 = CyclicPermutationGroup(2)
# sage: G_2 = CyclicPermutationGroup(2)
# sage: G_3 = SymmetricGroup(6)
# sage: groups = [G_1, G_2, G_3]
# sage: find_subdirect_products(groups)
# ===============================================
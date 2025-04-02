# This file will check if a finite group is covered by conjugates of r subgroups with indices n_1,...,n_r
# The motivation comes from number theory: The Galois group of a polynomial being covered in this way corresponds to having roots in the p-adic numbers Q_p for primes p not dividing the polynomial discriminant

# The following list encodes the necessary LMFDB abstract group labels that are too large for GAP
# Labels can be verified at, e.g., "https://beta.lmfdb.org/Groups/Abstract/2016.cw"
# This defines a matching between a finite permutation group (in terms of its generators) and the LMFDB label
# This can surely be done more elegantly

lmfdbMapping := [
    [ Group( (2,3,5,7,6,4)(9,10,11), (1,2,4,5)(3,6,7,8)(9,10) ), "2016.cw" ],
    [ Group( (1,3,5,7)(4,6)(8,9)(10,11), (1,2,4,3)(5,6)(9,10,11) ), "2016.cx" ],
    [ Group( (1,2,4,6,5,3)(7,8,9), (1,3)(2,5,4) ), "2160.bz" ],
    [ Group( (1,2,3,4,6)(7,9,8), (1,2,3,4,5)(7,8) ), "2160.ca" ],
    [ Group( (1,2,4,5,6,3)(7,8), (2,3,4)(7,8,9) ), "2160.cb" ],
    [ Group( (2,4)(6,7,10)(8,11,9), (1,2)(3,5,4)(6,8,10,9,7,11), (1,3,2,4)(6,9,7,8,10,11) ), "2160.ce" ],
    [ Group( (1,2,4,5,3)(7,8,9), (1,3,5)(2,4)(6,7)(8,10,9,11) ), "2160.cg" ],
    [ Group( (1,2,3,5)(6,8,9,11,7,10), (1,3,2,4,5)(6,7,9)(8,11,10), (1,2)(3,4)(7,9)(8,10) ), "2160.ch" ],
    [ Group( (1,3,4,5)(6,8)(7,9)(10,11), (1,2,3,4)(6,7)(9,10), (1,2,4,5,3)(6,9)(7,8)(10,11) ), "2160.ci" ],
    [ Group( (1,2,3,4,5)(6,8)(7,9,11,10), (2,3)(4,5)(6,7)(9,10) ), "2160.cj" ],
    [ Group( (1,2,3,4,5)(6,8,9,7,10,11), (2,3)(4,5)(6,7,9,8,10,11) ), "2160.cm" ],
    [ Group( (1,2,3)(4,5,6)(7,8,9)(10,11), (2,3,4,5,6)(10,11) ), "2160.cn" ],
    [ Group( (1,2,4,5,3)(6,7,8)(9,10,11), (1,3,4,2)(7,8)(9,11), (1,2,4,5,3)(6,8)(9,11) ), "2160.ct" ],
    [ Group( (1,2)(3,5)(4,6)(7,8)(9,10), (1,3,6,7,2,5)(4,8), (1,2)(5,7)(9,10), (1,4)(2,6)(3,5)(9,10), (3,7,5) ), "2304.ea" ],
    [ Group( (3,7)(6,8)(10,11), (2,6,7)(3,4,8), (1,2,5,4)(6,8), (3,7), (2,4)(3,7)(9,10,11), (1,3)(2,6)(4,8)(5,7) ), "2304.ey" ],
    [ Group( (1,2)(3,4,5)(7,8,9,10), (2,3,4,5)(6,7)(8,9) ), "2400.db" ],
    [ Group( (3,4,5,6,7), (1,2,3) ), "2520.a" ],
    [ Group( (1,3,4,7,8,6)(2,5,9)(10,11), (1,2,4,7,3,5)(6,9,8), (2,5)(3,6)(4,8)(7,9) ), "2592.cg" ],
    [ Group( (1,4,7)(2,3,6), (1,2)(3,4)(5,8)(6,7)(9,10), (1,3)(2,4)(5,8)(6,7), (1,3,2,5,4,7,6) ), "2688.cd" ],
    [ Group( (1,2,3,4)(5,6)(7,9)(8,10), (1,2,4,6)(7,10)(8,9), (2,3,5)(7,8)(9,10) ), "2880.du" ],
    [ Group( (2,3,4)(6,7,9,8), (1,2,3,5)(6,8) ), "2880.dv" ],
    [ Group( (1,2)(3,4,5,6)(8,9), (1,2,3,4,5)(7,8)(9,10) ), "2880.dx" ],
    [ Group( (1,2,3,5)(4,6)(7,8)(9,10), (1,3,6,2,4,5)(7,9) ), "2880.ea" ],
    [ Group( (1,2,4,3,5,6)(7,8)(9,10), (1,3,2,4,6)(7,9,8,10) ), "2880.eb" ],
    [ Group( (1,3,5,6,2,4)(8,10), (1,2)(3,5)(7,8,9,10) ), "2880.ec" ],
    [ Group( (1,2,3,4)(7,8)(10,11), (2,3)(6,7)(9,10), (1,2,3)(4,5)(6,8,9,11) ), "2880.eg" ],
    [ Group( (1,2,3,4,5)(7,8), (1,3,5,2)(6,7,9,11,8,10) ), "2880.eh" ],
    [ Group( (1,2,3)(6,8)(7,10)(9,11), (2,4)(3,5)(6,7)(8,10)(9,11), (1,2)(3,5)(6,7,9,10,8,11) ), "2880.ei" ],
    [ Group( (1,2)(4,5,6,7,9,8)(10,11), (1,3,2,4,6,8)(7,9) ), "3024.r" ],
    [ Group( (1,2,4,7,6,8)(3,5)(9,10), (1,3,6,4)(5,7,8)(10,11) ), "3456.cy" ],
    [ Group( (1,3,5,6,8,2,4,7)(9,10), (1,2)(3,5)(4,6)(7,8)(10,11) ), "3456.cz" ],
    [ Group( (1,3,6,7)(2,4)(5,8)(9,10), (1,2)(3,5,4,7)(6,8)(10,11) ), "3456.da" ],
    [ Group( (1,2)(3,5)(4,7,6,8)(9,11,10), (2,3,4,6)(9,10,11) ), "3456.db" ],
    [ Group( (1,3)(2,5)(4,6)(7,8), (10,11), (2,4)(6,7), (1,2,4), (9,10) ), "3456.di" ],
    [ Group( (1,2)(4,5,7)(6,8)(10,11), (1,3)(2,4,6,5)(7,8)(9,10,11) ), "3456.dj" ],
    [ Group( (1,3)(2,4)(6,8,10,7,9), (1,2,3,5,4)(6,7)(8,9) ), "3600.a" ],
    [ Group( (1,2,4,6,5)(7,8)(9,10), (1,3,5,6,4)(8,9)(10,11) ), "3600.ce" ],
    [ Group( (1,2,4,6)(3,5)(7,8,9,10,11), (1,3,2)(5,6)(7,9)(10,11) ), "3600.ch" ],
    [ Group( (1,2)(3,5,6)(7,8,10,11,9), (1,3)(2,4)(5,6)(7,9,11,10,8) ), "3600.cl" ],
    [ Group( (1,2)(3,4)(5,6)(7,8)(9,10,11), (1,3,5,4,6,7,2)(9,10,11) ), "4032.cj" ],
    [ Group( (1,3)(6,7)(10,11), (1,2,4,6)(3,5)(8,9,10) ), "4032.cl" ],
    [ Group( (1,3,5,4,6,2)(8,9), (1,2,5,3,6)(7,8), (1,4,2,6)(3,5)(7,8,9) ), "4320.bg" ],
    [ Group( (1,2,4)(3,5,6)(8,9,10), (1,3,2,4)(5,6)(7,8,10) ), "4320.bh" ],
    [ Group( (1,3)(2,5)(4,6)(7,9,8,10,11), (1,2,4)(5,6)(7,8)(9,11) ), "4320.bi" ],
    [ Group( (2,3)(4,5)(6,7), (1,2)(3,4,5)(6,8)(7,9,10,11) ), "4320.bk" ],
    [ Group( (1,4,2)(6,8,7,10)(9,11), (1,3,4)(2,5)(8,11,10), (1,2,5,4,3)(6,7,9) ), "4320.bl" ],
    [ Group( (1,3)(2,5)(6,8,11,10,7,9), (1,4,3,2,5)(6,8,7,10,11,9), (1,2)(3,4,5)(6,7)(9,10) ), "4320.bp" ],
    [ Group( (2,3,5,4)(8,10), (1,2)(3,4,5)(6,7,8,9,10,11) ), "4320.br" ],
    [ Group( (1,2)(3,4,5)(7,8,9)(10,11), (2,3,4,6,5)(7,8,9)(10,11) ), "4320.bt" ],
    [ Group( (1,3)(2,4,5,6)(7,8,9)(10,11), (1,2)(5,6)(8,9) ), "4320.bu" ],
    [ Group( (1,2,4,6,5,3)(7,8)(10,11), (1,3,2,5,4,6)(8,9) ), "4320.bv" ],
    [ Group( (1,3,5), (8,9), (1,2,4,6,5,7,3) ), "5040.v" ],
    [ Group( (1,2,3,4,5,6,7), (1,2) ), "5040.w" ],
    [ Group( (1,2)(3,4)(5,6), (7,8), (1,3)(4,5,6)(7,9)(8,10) ), "5760.ch" ],
    [ Group( (1,4,2)(3,5)(6,9,10)(7,11,8), (1,3,2,5,4)(6,8)(7,10,9,11), (1,2)(3,5,4)(6,7)(8,9)(10,11) ), "5760.co" ],
    [ Group( (1,3)(2,6,4,5)(7,8)(10,11), (1,2,4)(3,6)(10,11), (1,3,7,6,2,5,4,8)(9,10,11) ), "6912.br" ],
    [ Group( (1,2)(3,4,5)(7,9,10), (1,2,3)(6,7,8,9,10) ), "7200.br" ],
    [ Group( (1,2,3,5)(4,6)(8,10,11,9), (3,4,6)(7,8,9,10) ), "7200.ce" ],
    [ Group( (2,4)(3,5)(7,9)(10,11), (1,2,3,5,6,4)(7,8,9,10,11) ), "7200.cg" ],
    [ Group( (1,2,3)(4,5)(8,9,11,10), (2,3,4,6,5)(7,8,10,9,11) ), "7200.ck" ],
    [ Group( (1,2,3,4,5)(6,7,9), (2,4,5,3)(6,8,10,7), (1,2,4)(6,8,7,10,9) ), "7200.d" ],
    [ Group( (1,2,4,6,7,5,3)(8,9,10), (1,3,2,5)(6,7)(8,9,10) ), "7560.e" ],
    [ Group( (1,3,4,6,5,8,7)(9,11), (1,2)(4,5,7,8)(9,10) ), "8064.bp" ],
    [ Group( (1,2,4)(5,6)(7,9)(8,10), (2,3,4,5)(7,8,9) ), "8640.n" ],
    [ Group( (1,2)(3,4,5)(7,8), (1,2,3,4,6)(8,9,10) ), "8640.o" ],
    [ Group( (1,2,3,4)(5,6)(7,8,10), (2,4,5,6,3)(7,9,10,8) ), "8640.p" ],
    [ Group( (1,2,4,3,5)(6,7,9,8,10,11), (1,3)(2,4,5)(6,7,10,8)(9,11), (1,3,4,2,5)(6,8,10,11)(7,9) ), "8640.r" ],
    [ Group( (1,2,3,5,6,4)(7,9)(10,11), (2,4,3)(7,8), (1,3,6)(2,5)(7,8,9) ), "8640.t" ],
    [ Group( (3,4), (8,9), (1,2,3,4,5,6,7) ), "10080.l" ],
    [ Group( (1,2,4)(3,5,6,7)(8,9,10,11), (1,3,2,5,6)(8,10)(9,11) ), "10080.m" ],
    [ Group( (1,3,4,6,5,7,2)(8,10)(9,11), (1,2,4,5,7)(8,9)(10,11) ), "10080.n" ],
    [ Group( (1,2,4,7,6,3,5)(8,9,10,11), (2,3,5)(4,6,7) ), "10080.o" ],
    [ Group( (1,3,5)(2,4)(6,7)(8,9,10), (1,2,4)(7,9,10,8), (1,2,4)(6,8,9)(7,10) ), "14400.bg" ],
    [ Group( (1,3,4,5)(8,9)(10,11), (1,2,3)(5,6)(7,8,9,10) ), "14400.bj" ],
    [ Group( (1,2,4,5)(3,6,7)(8,9,10), (1,3,2,5,7,4) ), "15120.d" ],
    [ Group( (1,2,4,6,5)(8,9,10), (1,3,2,5)(4,7)(9,10) ), "15120.e" ],
    [ Group( (1,2,4,3,5)(8,9,10), (1,3,5,7)(2,4,6)(9,10) ), "15120.f" ],
    [ Group( (1,2)(3,4,5,6,7,8), (1,2,3) ), "20160.a" ],
    [ Group( (1,3,6)(4,7)(8,10,11,9), (1,2,4)(3,5)(6,7)(8,9)(10,11) ), "20160.i" ],
    [ Group( (1,2,3,4,5,6,7)(8,9), (1,2,3,5,7,6,4)(8,10)(9,11) ), "20160.j" ],
    [ Group( (2,3,5,4)(8,9,10,11), (1,2)(3,4,6)(5,7)(8,9,10,11) ), "20160.k" ],
    [ Group( (1,2,4,6)(8,9)(10,11), (1,3,2,5,4)(8,10)(9,11), (1,3,6,4,5,7,2)(8,11)(9,10) ), "20160.l" ],
    [ Group( (1,2,3,4)(5,6,7)(8,9), (2,3,5,6,7,4)(8,10)(9,11) ), "20160.m" ],
    [ Group( (1,2,3,4,5)(7,8,10,11,9), (4,5,6)(7,8,9,11,10) ), "21600.o" ],
    [ Group( (1,3,6,4,7,2,5)(8,9,10), (1,2,4,5)(3,6)(9,10,11) ), "30240.c" ],
    [ Group( (1,2,3,4,5,6,7,8), (1,2) ), "40320.a" ],
    [ Group( (1,2)(3,4,6,5,7,8), (1,3,5,7)(6,8)(9,10) ), "40320.i" ],
    [ Group( (1,3,2,5,4,6,7)(8,10,11,9), (1,2,4,7)(3,6,5)(8,9)(10,11), (1,3,5,6,2,4)(8,9,11,10) ), "40320.k" ],
    [ Group( (1,3)(2,4)(7,8,9,10), (1,2)(3,5,4,6)(8,10,11), (2,3,4,6,5)(7,9)(8,10) ), "43200.m" ],
    [ Group( (1,2,4,5,3,6)(7,8,9,10,11), (1,3,2,5,4)(9,11,10) ), "43200.n" ],
    [ Group( (1,3,5)(2,4)(7,9,11)(8,10), (1,2)(3,5,4,6)(7,8)(9,10) ), "43200.p" ],
    [ Group( (1,3,6,8,4,2,5)(9,11,10), (1,2,4)(3,6,5,7,8)(9,10,11) ), "60480.c" ],
    [ Group( (1,2,3,4,6)(5,7)(8,10,11), (3,4,5,6,7)(8,9,11) ), "60480.d" ],
    [ Group( (1,3)(2,5,4,7,6)(8,10,9,11), (1,2,4,7)(3,6)(8,9,10) ), "60480.e" ],
    [ Group( (1,3)(2,4,7)(5,6)(8,9,10), (1,2,3,5)(4,6)(10,11) ), "60480.f" ],
    [ Group( (1,2,3,4,6)(7,8,9,10), (1,3,5,2)(7,8,9,11) ), "86400.c" ],
    [ Group( (2,3,5,6,8)(4,7)(9,10,11), (1,2,4,3,6,8,7)(9,10,11) ), "120960.b" ],
    [ Group( (1,3,6,5,8,7,2,4)(9,11), (1,2,4,6)(3,5,7,8)(9,10,11) ), "120960.c" ],
    [ Group( (1,3,4,6,8)(2,5,7)(9,10,11), (1,2,4,3,5)(9,10) ), "120960.d" ],
    [ Group( (1,3,4,6,5,2)(8,9,11,10), (1,2,4,5,7,6)(8,9,10) ), "120960.e" ],
    [ Group( (2,3)(4,5,7,8)(9,10), (1,2,4,6,7,8,5,3)(9,11) ), "241920.a" ],
    [ Group( (1,2), (1,2,3,4,5,6,7,8,9) ), "362880.a" ],
    [ Group( (2,4,7)(3,5,8,9,6)(10,11), (1,2,3,4,6,8,7)(10,11) ), "362880.b" ],
    [ Group( (1,2,4,8,5,9)(3,6,7), (1,3,7,4,8,2,5,9)(10,11) ), "725760.a" ]
];

# This takes a group G as input, and if it's isomorphic to one of the groups above, then its labe (as a string) is returned

LMFDBLabel := function(G)
  local pair;
  for pair in lmfdbMapping do
    if IsIsomorphicGroup(G, pair[1]) then
      return pair[2];
    fi;
  od;
  return false;
end;

# This takes a group G as input and returns, as a string, either its small group ID (if it exists) or its LMFDB label from above
# Again, I'm sure there are many opportunities for elegance

GroupIdentifier := function(G)
    local id, label;

    # Try to compute IdGroup(G)

    id := fail;
    if HasIdGroup(G) then
        id := IdGroup(G);
    else
        id := fail;
    fi;

    if IsList(id) and Length(id) = 2 then
        return Concatenation(String(id[1]), ".", String(id[2]));
    else
        label := LMFDBLabel(G);
        if label <> false then
            return label;
        else
            return "UnknownGroup";  # or you can raise an error instead
        fi;
    fi;
end;

# Main function
# Inputs:
    # A finite group G
    # A list of positive integers which are the indices of the relevant subgroups
    # For example, you can call "CheckConjugateCovering(SmallGroup(72, 43), [2, 3, 3]);" or
      "CheckConjugateCovering(Group( (2,3,5,7,6,4)(9,10,11), (1,2,4,5)(3,6,7,8)(9,10) ), [4, 5]);"
# Outputs:
    # In the console: A set of union sizes, i.e., sizes of the union of conjugacy classes of relevant subgroups
    # These are listed in ascending order, without repeats, so for my purposes (checking if the union size is ever equal to the size of G), I really only need the last entry
    # More detailed output is stored in a .txt file for debugging, data analysis, etc.
    # The file path I used was "~\CheckConjugateCovering outputs\r=...", where "~" is the current working directory and "r=..." is the number of indices used
    # Output files are named like "64.264_2,8.txt". The first part, "x.y", is the group label (more on this later). The second part is the list of indices used as input
    # Output files should be self-explanatory to read, if not dense at times. The largest file I had was about 80 MB, but most are much smaller
    # In any case, beware of storage space limitations if using this code for very large groups

CheckConjugateCovering := function(G, indices)
    local cc, sortedIndices, subgroupLists, i, resultDict, allUnionSizes, processedTuples,
          subgroupTuple, HList, key, ccLists, tupleOfCCs, unionSubgroup, sizeUnion, sizeG,
          sizes, combination, j, sizeStr, ccEntry, logFile, s,
          id, groupIDStr, indicesStr, folderPath, filePath, split;
    
    # Determine output file name and folder based on input parameters

    id := GroupIdentifier(G);
    split := SplitString(id, ".");

    groupIDStr := JoinStringsWithSeparator(split, ".");
    indicesStr := JoinStringsWithSeparator(List(indices, String), ",");
    folderPath := Concatenation("C:/Users/User/OneDrive/Documents/CheckConjugateCovering outputs/r=", String(Length(indices)));
    filePath := Concatenation(folderPath, "/", groupIDStr, "_", indicesStr, ".txt");
    
    # Open a file for logging all detailed output

    logFile := OutputTextFile(filePath, false);
    
    cc := ConjugacyClassesSubgroups(G);

    # Sort the indices for consistent ordering / file naming

    sortedIndices := SortedList(indices);

    # For each index, get the list of conjugacy classes of subgroups with that index

    subgroupLists := List(sortedIndices, n -> Filtered(cc, x -> Index(G, Representative(x)) = n));

    # Check that there is at least one subgroup of each index

    for i in [1..Length(subgroupLists)] do
       if Length(subgroupLists[i]) = 0 then
          Error("No subgroups of index ", sortedIndices[i], " found in G.");
       fi;
    od;

    sizeG := Size(G);
    WriteLine(logFile, Concatenation("Size of group G: ", String(sizeG)));
    WriteLine(logFile, Concatenation("For indices ", JoinStringsWithSeparator(List(sortedIndices, String), ", "),
          ", i.e. subgroup sizes ",
          JoinStringsWithSeparator(List(sortedIndices, n -> String(sizeG/n)), ", ")));
    WriteLine(logFile, "");  # blank line
    
    # Initialize record for results and list for all union sizes (avoids repetition in the console output)

    resultDict := rec();
    allUnionSizes := [];
    processedTuples := rec();

    # Loop over all combinations of subgroup conjugacy classes (one from each subgroup list)

    for subgroupTuple in Cartesian(subgroupLists) do
         # Get subgroup representatives from the chosen conjugacy classes

         HList := List(subgroupTuple, x -> Representative(x));
         # Create a key based on the IdGroup of each subgroup to avoid duplicate processing

         key := JoinStringsWithSeparator(List(HList, H -> String(StructureDescription(H))), ",");
         if IsBound(processedTuples.(key)) then
              continue;
         fi;
         processedTuples.(key) := true;
         WriteLine(logFile, Concatenation("Subgroup Structure Descriptions: ", key));

         # For each subgroup in HList, get all conjugacy classes in cc which are isomorphic

         ccLists := List(HList, H -> Filtered(cc, x -> IsIsomorphicGroup(Representative(x),H)));

         # For every combination of conjugacy classes chosen from ccLists, compute the union of their subgroup elements
         for tupleOfCCs in Cartesian(ccLists) do
              unionSubgroup := [];
              for ccEntry in tupleOfCCs do
                  unionSubgroup := Union(unionSubgroup,
                                  Concatenation(List(Elements(ccEntry),
                                                      subgroup -> Elements(subgroup))));
              od;
              sizeUnion := Size(unionSubgroup);
              Add(allUnionSizes, sizeUnion);
              if not IsBound(resultDict.(String(sizeUnion))) then
                  resultDict.(String(sizeUnion)) := [];
              fi;
              Add(resultDict.(String(sizeUnion)), tupleOfCCs);
         od;
         WriteLine(logFile, "");  # blank line after processing one tuple
    od;

    # Print the results to the log file

    sizes := SortedList(RecNames(resultDict));
    WriteLine(logFile, "Union sizes and all combinations:");
    for sizeStr in sizes do
         WriteLine(logFile, Concatenation("Union size: ", sizeStr));
         if sizeStr = String(sizeG) then
              WriteLine(logFile, "  The union equals the full group G.");
         else
              WriteLine(logFile, "  The union is NOT equal to G.");
         fi;
         WriteLine(logFile, "  Combinations:");
         for combination in resultDict.(sizeStr) do
              s := "";
              for j in [1..Length(combination)] do
                  s := Concatenation(s, "cc[", String(j), "]= ", String(StructureDescription(Representative(combination[j]))), "  ");
              od;
              WriteLine(logFile, Concatenation("    ", s));
         od;
         WriteLine(logFile, "");
    od;
    
    allUnionSizes := SortedList(Set(allUnionSizes));
    
    CloseStream(logFile);
    
    # Print only the final set of possible union sizes to the GAP console
    Print("All possible union sizes: ", JoinStringsWithSeparator(List(allUnionSizes, String), ", "), "\n");
    
    return;
end;

# Example:
# When you load this function, it will automatically call this example. Comment the bottom line if it annoys you
# However, this is nice to check if the function is working. You can check that the output file is named "72.43_3,3,4,6.txt", and the union sizes in the console should only be 66 and 72

CheckConjugateCovering(SmallGroup(72, 43), [3, 3, 4, 6]);
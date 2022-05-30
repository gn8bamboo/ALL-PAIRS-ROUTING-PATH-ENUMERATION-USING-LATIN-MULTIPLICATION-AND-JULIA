# Determines whether given path violates the loop rule
# @param Potential_Path The path not verified
# @return [] if break loop rule
# @return Advanced_Potential_Path if pass loop rule
function Check_Loop(Potential_Path)
  if Potential_Path == union(Potential_Path)
    Advanced_Potential_Path = Potential_Path
  else
    Advanced_Potential_Path = []
  end
  return Advanced_Potential_Path
end


# Find Business Relationship Pattern for given path
# @ param Potential_Path The path not verified
# @ param relationshipMatrix Each matrix element indicates business relationship
#                     between two nodes.
# @return Relationship_Pattern Relationship Pattern for given path
function Find_Relationship(Potential_Path,relationshipMatrix)

    Relationship_Pattern = Vector()
    globalsize = length(Potential_Path)
    pathsize =  length(Potential_Path[1])

    if globalsize != 0 && pathsize != 2
        for i = 1:globalsize-1
            a = Potential_Path[i]
            b = Potential_Path[i+1]
            temp = relationshipMatrix[a,b]
            push!(Relationship_Pattern,temp)
        end
    else
        Relationship_Pattern = []
    end
    return Relationship_Pattern
end

# Determines whether Relationship_Pattern is in Invalidation_Pattern
# @ param Invalidation_Pattern
# @ param Relationship_Pattern
# @ return Ture Relationship_Pattern in Invalidation_Pattern
# @ return False Relationship_Pattern not in Invalidation_Pattern
function isin(Invalidation_Pattern,Relationship_Pattern)

    n = length(Invalidation_Pattern)
    flag = false

    if n == 2
        a = Invalidation_Pattern[1]
        b = Invalidation_Pattern[2]

        list = findall(x->x == a, Relationship_Pattern)

        m = length(list)
        for i = 1:m
            j = list[i]
            if j+ n-1 <= length(Relationship_Pattern)&& Relationship_Pattern[j] == a && Relationship_Pattern[j+1] == b
                flag = true
                break
            else
                flag = false
            end
        end

    else
        a = Invalidation_Pattern[1]
        b = Invalidation_Pattern[2]
        c = Invalidation_Pattern[3]

        list = findall(x->x == a, Relationship_Pattern)

        m = length(list)
        for i = 1:m
            j = list[i]
            if j+ n-1 <= length(Relationship_Pattern)&& Relationship_Pattern[j] == a && Relationship_Pattern[j+1] == b && Relationship_Pattern[j+2] == c c
                flag = true
                break
            else
                flag = false
            end
        end
    end
    return flag
end

# Determines whether given path violates the valley-free rule
# @param Advanced_Potential_Path The path pass the loop
# @param relationshipMatrix Each matrix element indicates business relationship
#                   between two nodes.
# @return [] if break valley-free rule
# @return Passed_Path if pass valley-free rule
function Check_Relationship(Advanced_Potential_Path,relationshipMatrix)

    Passed_Path = []
    Relationship_Pattern = Find_Relationship(Advanced_Potential_Path,relationshipMatrix)

    Invalidation_Pattern = Vector(undef,13)
    Invalidation_Pattern[1] = [1,2]
    Invalidation_Pattern[2] = [1,3]
    Invalidation_Pattern[3] = [3,2]
    Invalidation_Pattern[4] = [3,3]
    Invalidation_Pattern[5] = [3,1,2]
    Invalidation_Pattern[6] = [2,1,2]
    Invalidation_Pattern[7] = [1,1,2]
    Invalidation_Pattern[8] = [3,1,3]
    Invalidation_Pattern[9] = [2,1,3]
    Invalidation_Pattern[10] = [1,1,3]
    Invalidation_Pattern[11] = [2,3,2]
    Invalidation_Pattern[12] = [2,3,3]
    Invalidation_Pattern[13] = [3,1,3]

    for i = 1:13
        flag = isin(Invalidation_Pattern[i],Relationship_Pattern)
        if flag == true
            Passed_Path = []
            break
        else
            Passed_Path = Advanced_Potential_Path
        end
    end

  return Passed_Path
end


# Determines whether given path violates the loop and valley-free rule
# @param Potential_Path The path not verified
# @param typeMatrix Each matrix element indicates business relationship
#                   between two nodes.
# @return Passed_Path if pass loop and valley-free rule
function Path_Validator(Potential_Path,relationshipMatrix)
    Passed_Path = []
    Advanced_Potential_Path = Check_Loop(Potential_Path)
    if Advanced_Potential_Path != []
        Passed_Path = Check_Relationship(Advanced_Potential_Path,relationshipMatrix)
    end

    return Passed_Path
end

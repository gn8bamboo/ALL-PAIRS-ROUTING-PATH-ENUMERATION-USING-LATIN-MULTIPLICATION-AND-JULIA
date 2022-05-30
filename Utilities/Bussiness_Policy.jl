# Based on the type of AS, set local preference value for each AS
#  Tier-1: rand value between 1 to 6
#  Tier-X: rand value between 1 to 3
#  Stubs: fixed value = 1
# @param ispn: number of AS
# @param nTier_1: number of Tier-1 AS
# @param nTier_X: number of Tier-X AS
# @return ISP_Local_Preference: local_preference_value vector
function Set_Local_Preference(ispn,nTier_1,nTier_X)
    ISP_Local_Preference = Matrix(undef,ispn,2)

    for i = 1:ispn
        if i <= nTier_1
            local_preference_value = rand(1:6)
        elseif nTier_1 < i <= nTier_1 + nTier_X
            local_preference_value = rand(1:3)
        else
            local_preference_value = 1
        end

        ISP_Local_Preference[i,1] = i
        ISP_Local_Preference[i,2] = local_preference_value

    end
    return ISP_Local_Preference
end

# Find total local prefernce value for given path
# @param Path: path
# @param ISP_Local_Preference: local preference value vector
# @return total_value: total local prefernce value for given path
function Path_Local_Preference_Value(Path,ISP_Local_Preference)
    total_value = 0
    for i in Path
        total_value = total_value + ISP_Local_Preference[i,2]
    end
    return total_value
end

# Find Euclidean distance between two points
# @param P1, P2: Given points
# @return Dis: Euclidean distance between two points
function Euclidean_Dis(P1,P2)
    x1 = P1.x
    y1 = P1.y
    x2 = P2.x
    y2 = P2.y

    Dis = sqrt((x2 - x1)^2 + (y2 - y1)^2)
    return Dis
end

# Find total Euclidean distance for given path
# @param Path: path
# @param ISP_Location: Location file of each ASes
# @return total_dis: total Euclidean distance for given path
function Path_Distance(Path,ISP_Location)
    n = length(Path)
    total_dis = 0

    for i = 1:n-1
        a = Path[i]
        b = Path[i+1]
        P1 = ISP_Location[a].center
        P2 = ISP_Location[b].center

        dis = Euclidean_Dis(P1,P2)
        total_dis = total_dis + dis
    end

    return total_dis
end


# Based on business policy to find which path is prefered path
# @param Current_Path: current path
# @param Potential_Path: potential path
# @param ISP_Local_Preference: local preference value vector
# @param ISP_Location: Location file of each ASes
# @return Prefer_Path: prefered path based on policy
function Business_Policy(Current_Path,Potential_Path,ISP_Local_Preference,ISP_Location)
    Prefer_Path = []
    current_value = Path_Local_Preference_Value(Current_Path,ISP_Local_Preference)
    potential_value = Path_Local_Preference_Value(Potential_Path,ISP_Local_Preference)
    current_dis = Path_Distance(Current_Path,ISP_Location)
    potential_dis = Path_Distance(Potential_Path,ISP_Location)

    if potential_value > current_value
        Prefer_Path = Potential_Path
    end

    if potential_value < current_value
        Prefer_Path = Current_Path
    end

    if potential_value == current_value
        if current_dis >= potential_dis
            Prefer_Path = Potential_Path
        else
            Prefer_Path = Current_Path
        end
    end
    return Prefer_Path
end

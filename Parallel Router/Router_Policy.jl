# Finding path distance between two path
# @param AS_Path: AS level path
# @param Router_Path: router level path
# @param ISP_Router_Location: xy router location
# @return res: distance between two routers
function Routing_Path_Distance(AS_Path,Router_Path,ISP_Router_Location)
    if typeof(Router_Path) == String
        n = 1
        res = Matrix(undef,n,4)
        fill!(res,"")
        res[1,1] = AS_Path
        res[1,2] = Router_Path
        temp_list = split(Router_Path," --> ")
        m = length(temp_list)
        sum = 0
        for j = 1:m-1
            as1 = parse(Int,split(temp_list[j],"-")[1][3:end])
            r1 = parse(Int,split(temp_list[j],"-")[end][2:end])
            as2 = parse(Int,split(temp_list[j+1],"-")[1][3:end])
            r2 = parse(Int,split(temp_list[j+1],"-")[end][2:end])

            R1_loc = ISP_Router_Location[as1][:,1][r1]
            R2_loc = ISP_Router_Location[as2][:,1][r2]

            dis = Euclidean_Dis(R1_loc,R2_loc)
            sum = sum + dis
        end
        res[1,3] = sum
    else
        n = length(Router_Path)
        res = Matrix(undef,n,4)
        fill!(res,"")
        res[1,1] = AS_Path

        for i = 1:n
            res[i,2] = Router_Path[i]
            temp_list = split(Router_Path[i]," --> ")
            m = length(temp_list)
            sum = 0
            for j = 1:m-1
                as1 = parse(Int,split(temp_list[j],"-")[1][3:end])
                r1 = parse(Int,split(temp_list[j],"-")[end][2:end])
                as2 = parse(Int,split(temp_list[j+1],"-")[1][3:end])
                r2 = parse(Int,split(temp_list[j+1],"-")[end][2:end])

                R1_loc = ISP_Router_Location[as1][:,1][r1]
                R2_loc = ISP_Router_Location[as2][:,1][r2]

                dis = Euclidean_Dis(R1_loc,R2_loc)
                sum = sum + dis
            end
            res[i,3] = sum
        end
    end

    return res
end

# Finding Prefer_Shortest_Path result for given origin AS and target AS
# @param RT: AS level path
# @param Pair_RT: router level path
# @param ISP_Router_Location: xy router location
# @param origin: origin AS
# @param dest: target AS
# @return df: Prefer_Shortest_Path result in DataFrame
function Prefer_Shortest_Path(RT,Pair_RT,ISP_Router_Location,origin,dest)

    Path_List = RT[origin,dest]
    Routing_Path_List = Pair_RT[origin,dest]
    n = length(Path_List)
    Shortest_res_Vec = Vector(undef,n)

    for i = 1:n
        AS_Path = Path_List[i]
        Router_Path = Routing_Path_List[i]
        res = Routing_Path_Distance(AS_Path,Router_Path,ISP_Router_Location)
        Shortest_res_Vec[i] = res
    end

    Shortest_res_Matrix = Shortest_res_Vec[1]
    for ii = 2:n
        Shortest_res_Matrix = vcat(Shortest_res_Matrix,Shortest_res_Vec[ii])
    end

    idx = findmin(Shortest_res_Matrix[:,3])[2]
    Shortest_res_Matrix[idx,4] = "Yes"

    df = DataFrame()
    df.AS_Path = Shortest_res_Matrix[:,1]
    df.Router_path = Shortest_res_Matrix[:,2]
    df.Prefer_Shortest = Shortest_res_Matrix[:,4]

    return df

    return Shortest_res_Matrix
end

# Finding path neighor between two path
# @param AS_Path: AS level path
# @param Router_Path: router level path
# @param ISP_Router_Location: xy router location
# @return res: neighor between two routers
function Path_Neighor(AS_Path,Router_Path,ISP_Router_Location)
    if typeof(Router_Path) == String
        n = 1
        res = Matrix(undef,n,5)
        fill!(res,"")
        res[1,1] = AS_Path
        res[1,2] = Router_Path
        sum = 0
        temp = split(Router_Path," --> ")
        AS1 = parse(Int,split(temp[1],"-")[1][3:end])
        R1 = parse(Int,split(temp[1],"-")[end][2:end])
        AS2 = parse(Int,split(temp[2],"-")[1][3:end])
        R2 = parse(Int,split(temp[2],"-")[2][2:end])

        R1_loc = ISP_Router_Location[AS1][:,1][R1]
        R2_loc = ISP_Router_Location[AS2][:,1][R2]

        dis = Euclidean_Dis(R1_loc,R2_loc)
        sum = sum + dis

        res[1,3] = AS2
        res[1,4] = sum
    else
        n = length(Router_Path)
        res = Matrix(undef,n,5)
        fill!(res,"")
        res[1,1] = AS_Path

        for i = 1:n
            res[i,2] = Router_Path[i]
            sum = 0
            temp = split(Router_Path[i]," --> ")
            AS1 = parse(Int,split(temp[1],"-")[1][3:end])
            R1 = parse(Int,split(temp[1],"-")[end][2:end])
            AS2 = parse(Int,split(temp[2],"-")[1][3:end])
            R2 = parse(Int,split(temp[2],"-")[2][2:end])

            R1_loc = ISP_Router_Location[AS1][:,1][R1]
            R2_loc = ISP_Router_Location[AS2][:,1][R2]

            dis = Euclidean_Dis(R1_loc,R2_loc)
            sum = sum + dis

            res[i,3] = AS2
            res[i,4] = sum
        end
    end
    return res
end

# Finding Prefer_Neighbor result for given origin AS and target AS
# @param RT: AS level path
# @param Pair_RT: router level path
# @param ISP_Router_Location: xy router location
# @param origin: origin AS
# @param dest: target AS
# @return df: Prefer_Neighbor result in DataFrame
function Prefer_Neighbor(RT,Pair_RT,ISP_Router_Location,origin,dest)

    Path_List = RT[origin,dest]
    Router_List = Pair_RT[origin,dest]
    n = length(Path_List)
    Neighbor_res_Vec = Vector(undef,n)

    for i = 1:n
        AS_Path = Path_List[i]
        Router_Path = Router_List[i]
        res = Path_Neighor(AS_Path,Router_Path,ISP_Router_Location)
        Neighbor_res_Vec[i] = res
    end

    Neighbor_res_Matrix = Neighbor_res_Vec[1]
    for ii = 2:n
        Neighbor_res_Matrix = vcat(Neighbor_res_Matrix,Neighbor_res_Vec[ii])
    end

    idx = findmin(Neighbor_res_Matrix[:,4])[2]
    Neighbor_res_Matrix[idx,5] = "Yes"
    df = DataFrame()
    df.AS_Path = Neighbor_res_Matrix[:,1]
    df.Router_path = Neighbor_res_Matrix[:,2]
    df.Prefer_Neighbor = Neighbor_res_Matrix[:,5]


    return df
end

# Finding path Preference_Value between two path
# @param AS_Path: AS level path
# @param Router_Path: router level path
# @param ISP_Router_Location: xy router location
# @return res: path Preference_Value between two path
function Preference_Value(AS_Path,Router_Path,ISP_Router_Location)
    if typeof(Router_Path) == String
        n = 1
        res = Matrix(undef,n,4)
        fill!(res,"")
        res[1,1] = AS_Path
        res[1,2] = Router_Path
        temp = split(Router_Path," --> ")
        sum = 0
        for i = 2:length(temp)
            as = parse(Int,split(temp[i],"-")[1][3:end])
            r = parse(Int,split(temp[i],"-")[2][2:end])
            local_value = ISP_Router_Location[as][:,2][r]
            sum = sum + local_value
        end
        res[1,3] = sum

    else
        n = length(Router_Path)
        res = Matrix(undef,n,4)
        fill!(res,"")
        res[1,1] = AS_Path
        for i = 1:n
            res[i,2] = Router_Path[i]
            temp = split(Router_Path[i]," --> ")
            sum = 0
            for j = 2:length(temp)
                as = parse(Int,split(temp[j],"-")[1][3:end])
                r = parse(Int,split(temp[j],"-")[2][2:end])
                local_value = ISP_Router_Location[as][:,2][r]
                sum = sum + local_value
            end

            res[i,3] = sum
        end
    end

    return res
end

# Finding Prefer_Local_Preference_Value result for given origin AS and target AS
# @param RT: AS level path
# @param Pair_RT: router level path
# @param ISP_Router_Location: xy router location
# @param origin: origin AS
# @param dest: target AS
# @return df: Prefer_Local_Preference_Value result in DataFrame
function Prefer_Local(RT,Pair_RT,ISP_Router_Location,origin,dest)

    Path_List = RT[origin,dest]
    Router_List = Pair_RT[origin,dest]
    n = length(Path_List)
    Local_res_Vec = Vector(undef,n)

    for i = 1:n
        AS_Path = Path_List[i]
        Router_Path = Router_List[i]
        res = Preference_Value(AS_Path,Router_Path,ISP_Router_Location)
        Local_res_Vec[i] = res
    end

    Local_res_Matrix = Local_res_Vec[1]
    for ii = 2:n
        Local_res_Matrix = vcat(Local_res_Matrix,Local_res_Vec[ii])
    end

    idx = findmax(Local_res_Matrix[:,4])[2]
    Local_res_Matrix[idx,4] = "Yes"
    df = DataFrame()
    df.AS_Path = Local_res_Matrix[:,1]
    df.Router_path = Local_res_Matrix[:,2]
    df.Prefer_Local = Local_res_Matrix[:,4]

    return df
end

# Combine Prefer_Shortest_Path, Prefer_Neighbor and Prefer_Local in one function
# @param RT: AS level path
# @param Pair_RT: router level path
# @param ISP_Router_Location: xy router location
# @param origin: origin AS
# @param dest: target AS
# @return df: Prefer_Shortest_Path, Prefer_Neighbor and Prefer_Local result in DataFrame
function Router_Policy(RT,Pair_RT,ISP_Router_Location,origin,dest)
    df1 = Prefer_Shortest_Path(RT,Pair_RT,ISP_Router_Location,origin,dest)
    df2 = Prefer_Neighbor(RT,Pair_RT,ISP_Router_Location,origin,dest)
    df3 = Prefer_Local(RT,Pair_RT,ISP_Router_Location,origin,dest)

    df = df1
    df.Prefer_Neighbor = df2[:,3]
    df.Prefer_Local = df3[:,3]

    return df
end



function Print_Router_Policy(df,filename)
    f = open(filename,"a")
    n = size(df)[1]
    Path_List = df.AS_Path
    i = Path_List[1][1]
    j = Path_List[1][end]
    println(f,"There are $n Routing Paths From AS-$i to AS-$j.")
    println(f,df)
    println(f,"\n")
    close(f)
end

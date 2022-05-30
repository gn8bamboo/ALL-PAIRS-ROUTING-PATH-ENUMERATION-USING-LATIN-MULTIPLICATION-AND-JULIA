# Check whether the point is in the ellipse
# @param p: point
# @param e: ellipse
# @return true: point in the ellipse
# @return false: point not in the ellipse
function pisine(p::Point, e::Ellipse)
    #Given Point x,y
    x = p.x
    y = p.y

    h = e.center.x
    k = e.center.y
    rx = e.a
    ry = e.b
    th = e.theta

    dx  = x - rx
    dy  = y - ry

    co = cos(th)
    si = sin(th)

    tdx = (co * dx) + (si * dy)
    tdy = (si * dx) - (co * dy)

    t1 = tdx^2 / rx^2
    t2 = tdy^2 / ry^2

    if t1 + t2 < 1
        return true
    else
        return false
    end
end

# Generate given number of router in each AS, and give each router local preference
# @param ISP_Location: location of AS
# @param nRouters: number of routers
# @return R: location of each router and its local preference
function Generate_Router(ISP_Location,nRouters)
    R =  Matrix(undef,nRouters,2)

    for i = 1:nRouters
        point = rand(Point)
        while pisine(point,ISP_Location) == false
            point = rand(Point)
        end
        R[i,1] = point
        R[i,2] = rand(1:6)
    end
    return R
end


# Based on the type of AS, to generate the routers for each AS.
        # Tier-1: 5
        # Tier-X: 3
        # Stubs: 1
# @param ISP_Location: location of AS
# @param ispn: total number of ISPs (Tier-1,Tier-x,stubs)
# @param nTier_1: # of Tier-1 ISPs
# @param nTier_X: # of Tier-X ISPs
# @return ISP_Router_Location: every router location for each AS
function Fixed_Set_Routers(ISP_Location,ispn,nTier_1,nTier_X)
    ISP_Router_Location = Vector()

    for i = 1:ispn
        if i <= nTier_1
            nRouters = 5
            R = Generate_Router(ISP_Location[i],nRouters)
        elseif nTier_1 < i <= nTier_1 + nTier_X
            nRouters = 3
            R = Generate_Router(ISP_Location[i],nRouters)
        else
            nRouters = 1
            R = Generate_Router(ISP_Location[i],nRouters)
        end
        push!(ISP_Router_Location,R)

    end

    return ISP_Router_Location
end

# Find the single router pair based on the smallest distance
# @param R1_Vec: router location list
# @param R2_Vec: router location list
# @return router_pair based on the R1_Vec and R2_Vec
function Router_Distance_Single(R1_Vec,R2_Vec)
    n = length(R1_Vec)
    m = length(R2_Vec)
    idxVector = Vector()
    dVector = Vector()

    for i = 1:n
        for j = 1:m
            push!(idxVector,[i,j])
            dis = Euclidean_Dis(R1_Vec[i],R2_Vec[j])
            push!(dVector,dis)
        end
    end

    idx = findmin(dVector)[2]
    router_pair = [idxVector[idx],1]

    return router_pair
end

# Generate Router Matrix
# @param ISP_Router_Location: every router location for each AS
# @return Single_RMatrix: single pair Router Matrix
function Border_Router_Single(ISP_Router_Location)
    n = length(ISP_Router_Location)
    Single_RMatrix = Matrix(undef,n,n)

    for i = 1:n
        for j = 1:n
            R1_Vec = ISP_Router_Location[i][:,1]
            R2_Vec = ISP_Router_Location[j][:,1]
            router_pair = Router_Distance_Single(R1_Vec,R2_Vec)
            Single_RMatrix[i,j] = router_pair
        end
    end

    return Single_RMatrix
end

# Find the mulit router pair based on the smallest distance and biggest distance
# @param R1_Vec: router location list
# @param R2_Vec: router location list
# @return router_pair based on the R1_Vec and R2_Vec
function Router_Distance_Multi(R1_Vec,R2_Vec)
    n = length(R1_Vec)
    m = length(R2_Vec)
    idxVector = Vector()
    dVector = Vector()

    for i = 1:n
        for j = 1:m
            push!(idxVector,[i,j])
            dis = Euclidean_Dis(R1_Vec[i],R2_Vec[j])
            push!(dVector,dis)
        end
    end

    idmin = findmin(dVector)[2]
    idmax = findmax(dVector)[2]
    if idmin == idmax
        router_pair = [idxVector[idmin],1]
    else
        router_pair = [idxVector[idmin],idxVector[idmax],2]
    end

    return router_pair
end

# Generate Router Matrix
# @param ISP_Router_Location: every router location for each AS
# @return Multi_RMatrix: multi pair Router Matrix
function Border_Router_Multi(ISP_Router_Location)
    n = length(ISP_Router_Location)
    Multi_RMatrix = Matrix(undef,n,n)

    for i = 1:n
        for j = 1:n
            R1_Vec = ISP_Router_Location[i][:,1]
            R2_Vec = ISP_Router_Location[j][:,1]
            router_pair = Router_Distance_Multi(R1_Vec,R2_Vec)
            Multi_RMatrix[i,j] = router_pair
        end
    end

    return Multi_RMatrix
end

# find detailed router connection status between as1 and as2
# @param as1: AS number
# @param as2: AS number
# @return txtVec: detailed connection status of as1 and as2
function Two_Nodes_Connection(as1,as2,RMatrix)
    n = RMatrix[as1,as2][end]
    txtVec = []

    if n == 1
        r1 = RMatrix[as1,as2][1][1]
        r2 = RMatrix[as1,as2][1][2]
        txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2)"
        push!(txtVec,txt)
    else
        for i = 1:n
            r1 = RMatrix[as1,as2][i][1]
            r2 = RMatrix[as1,as2][i][2]
            txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2)"
            push!(txtVec,txt)
        end
    end
    return txtVec
end

# find detailed router connection status between as1 and as2
# @param as1: AS number
# @param as2: AS number
# @param asN: AS number
# @return txtVec: detailed connection status of as1 and as2
function Three_Nodes_Connection(as1,as2,asN,RMatrix)
    n = RMatrix[as1,as2][end]
    txtVec = []

    if n == 1
        r1 = RMatrix[as1,as2][1][1]
        r2 = RMatrix[as1,as2][1][2]
        rN = RMatrix[as2,asN][1][1]
        if r2 != rN
            txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2) --> AS$(as2)-R$(rN)"
            push!(txtVec,txt)
        else
            txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2)"
            push!(txtVec,txt)
        end
    else
        for i = 1:n
            r1 = RMatrix[as1,as2][i][1]
            r2 = RMatrix[as1,as2][i][2]
            rN = RMatrix[as2,asN][i][1]
            if r2 != rN
                txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2) --> AS$(as2)-R$(rN)"
                push!(txtVec,txt)
            else
                txt = "AS$(as1)-R$(r1) --> AS$(as2)-R$(r2)"
                push!(txtVec,txt)
            end
        end
    end

    return txtVec
end

# Find router level path for give AS path
# @param path: AS path
# @param RMatrix: Router Matrix
# @param m: m = 1, Single_RMatrix; m = 2, Multi_RMatrix
# @return Router_Path: router level path
function Deal_Single_Path(path,RMatrix,m)
    n = length(path)
    Res_Matrix = Matrix(undef,m,n-1)
    fill!(Res_Matrix,0)

    for i = 1:n-1
        as1 = path[i]
        as2 = path[i+1]
        if i < n-1
            asN = path[i+2]
            txt = Three_Nodes_Connection(as1,as2,asN,RMatrix)
            for j = 1:length(txt)
                Res_Matrix[j,i] = txt[j]
            end
        else
            txt = Two_Nodes_Connection(as1,as2,RMatrix)
            for j = 1:length(txt)
                Res_Matrix[j,i] = txt[j]
            end
        end
    end

    if m == 1
        Router_Path = Deal_Single_Pair(Res_Matrix,n)
    end
    if m == 2
        Router_Path = Deal_Multi_Pair(Res_Matrix,n)
    end
    return Router_Path
end

# Support function for Deal_Single_Path to find router level path
function Deal_Single_Pair(Res_Matrix,n)
    res = Res_Matrix[1]
    for p = 2:n-1
        temp1 = split(res," --> ")
        temp2 = split(Res_Matrix[p]," --> ")
        if temp1[end] == temp2[1]
            res = res* " --> " *temp2[2]
        else
            res = res* " --> " *Res_Matrix[p]
        end
    end
    return res
end

# Support function for Deal_Single_Path to find router level path
function Deal_Multi_Pair(Res_Matrix,n)

    res1 = Res_Matrix[:,1]
    for p = 2:n-1
        res2 = Res_Matrix[:,p]
        tempres = []
        for i = 1:length(res1)
            for j = 1:length(res2)
                if res1[i] != 0 && res2[j] != 0
                    temp1 = split(res1[i]," --> ")
                    temp2 = split(res2[j]," --> ")
                    if temp1[end] == temp2[1]
                        txt = res1[i] * " --> " * temp2[2]
                        push!(tempres,txt)
                    else
                        txt = res1[i] * " --> " * res2[j]
                        push!(tempres,txt)
                    end
                end
            end
        end
        res1 = tempres
    end
    res1
end

# Find all router level path for give AS path list
# @param Path_List: AS path list
# @param RMatrix: Router Matrix
# @param m: m = 1, Single_RMatrix; m = 2, Multi_RMatrix
# @return Router_Path_List: all router level path
function Deal_Path_List(Path_List,RMatrix,m)
    Router_Path_List = []
    n = length(Path_List)
    if m == 1
        for i = 1:n
            path = Path_List[i]
            new_path = Deal_Single_Path(path,RMatrix,m)
            push!(Router_Path_List,new_path)
        end
    end

    if m == 2
        for i = 1:n
            path = Path_List[i]
            new_path = Deal_Single_Path(path,RMatrix,m)
            push!(Router_Path_List,new_path)
        end
    end

    return Router_Path_List
end


# Find router level path matrix for whole network
# @param RT: Routing Table
# @param ispn: total number of ISPs (Tier-1,Tier-x,stubs)
# @param RMatrix: Router Matrix
# @param m: m = 1, Single_RMatrix; m = 2, Multi_RMatrix
# @return Pair_RT: router level path matrix
function Pair_Routing_Table(RT,ispn,RMatrix,m)
    Single_Pair_RT = Matrix(undef,ispn,ispn)

    for i = 1:ispn
        for j = 1:ispn
            if RT[i,j] != []
                Path_List = RT[i,j]
                Router_Path_List = Deal_Path_List(Path_List,RMatrix,m)
                Single_Pair_RT[i,j] = Router_Path_List
            else
                Single_Pair_RT[i,j] = []
            end
        end
    end
    return Single_Pair_RT
end

# parallel LM method iteration method
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
# @return iter: number of iteration
# @return Single_RMatrix: single pair the routing table
# @return Multi_RMatrix: multi pair the routing table
function Router_Level_Simulation(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location,ispn,Single_RMatrix,Multi_RMatrix)
    #RT,iter = iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    RT,iter = Para_Iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    Single_Pair_RT = Pair_Routing_Table(RT,ispn,Single_RMatrix,1)
    Multi_Pair_RT = Pair_Routing_Table(RT,ispn,Multi_RMatrix,2)

    return RT,iter,Single_Pair_RT,Multi_Pair_RT
end

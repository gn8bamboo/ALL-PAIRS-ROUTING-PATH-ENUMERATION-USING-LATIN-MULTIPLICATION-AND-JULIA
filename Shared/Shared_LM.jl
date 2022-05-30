# The LM method
# @param Shared_Path_Matrix: The matrix include path info. between two nodes.
# @param Shared_Link_Matrix: contains the adjacent links of the topology
#          and does not change throughoutthe simulation process
# @param Routing_Table: Routing Table
# @return res: all possible path between two nodes
# @cite: M. Gondran and M. Minoux, Graphs, Dioids and Semirings: New Models and Algorithms
function LM_Method(Shared_Path_Matrix,Shared_Link_Matrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    nrow,ncol = size(Shared_Path_Matrix)
    #N = length(Shared_Path_Matrix[1,1].p) + 1
    #res = SharedArray{Path{N},2}(nrow,ncol)
    res = Matrix(undef,nrow,ncol)
    fill!(res,0)

    for i = 1:nrow
        for j = 1:ncol
            for k = 1:ncol
                if Shared_Path_Matrix[i,j].d != 0 && Shared_Link_Matrix[j,k].o!=0
                    X = collect(Shared_Path_Matrix[i,j].p)
                    Y = collect(Shared_Link_Matrix[j,k].p)[2:end]
                    Potential_Path = [X;Y]
                    Passed_Path = Path_Validator(Potential_Path,relationshipMatrix)
                    if Passed_Path != []
                        if res[i,k] == 0
                            #o = Potential_Path[1]
                            #d = Potential_Path[end]
                            #p = Tuple(Potential_Path)
                            res[i,k] = Potential_Path
                        else
                            Current_Path = res[i,k]
                            Prefer_Path = Business_Policy(Current_Path,Potential_Path,ISP_Local_Preference,ISP_Location)
                            #o = Prefer_Path[1]
                            #d = Prefer_Path[end]
                            #p = Tuple(Prefer_Path)
                            res[i,k] = Prefer_Path
                        end
                    end
                end
            end
        end
    end

    #Shared_Path_Matrix = res
    #Routing_Table = Store_Path_Matrix(Routing_Table,Shared_Path_Matrix)
    #return Shared_Path_Matrix,Routing_Table
    return res
end


# The Shared_LM method, in this function will call LM Method
# @param Shared_Path_Matrix: The matrix include path info. between two nodes.
# @param Shared_Link_Matrix: contains the adjacent links of the topology
#          and does not change throughoutthe simulation process
# @param Routing_Table: Routing Table
# @return Routing_Table: Routing Table
# @return Shared_Path_Matrix: The matrix include path info. between two nodes.
function Shared_LM_Method(Shared_Path_Matrix,Shared_Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    res = Vector(undef,nworkers())
    nchunks = length(workers())
    n = size(Shared_Link_Matrix)[1]

    spiltrange = Vector(undef,nworkers())
    remainder = mod(n,nchunks)


    if remainder == 0
        for (idx, pid) in enumerate(workers())
            spiltrange[idx] = 1+(pid-2) * div(n,nchunks) : (pid-1) * div(n,nchunks)
        end
    else
        for (idx, pid) in enumerate(workers())
            spiltrange[idx] = 1+(pid-2) * div(n,nchunks) : (pid-1) * div(n,nchunks)
        end
        spiltrange[end] = spiltrange[end][1]:spiltrange[end][end] + remainder
    end


    @sync for (idx, pid) in enumerate(workers())
        Sub_Shared_Path_Matrix = Shared_Path_Matrix[spiltrange[idx],:]
        @async res[idx] = fetch(remotecall_wait(LM_Method,pid,Sub_Shared_Path_Matrix,Shared_Link_Matrix,relationshipMatrix,ISP_Local_Preference,ISP_Location))
    end

    M = Matrix(undef,n,n)
    fill!(M,0)
    for (idx, pid) in enumerate(workers())
        M[spiltrange[idx],:] = res[idx]
    end

    nrow,ncol = size(M)
    N = length(Shared_Path_Matrix[1,1].p) + 1
    Shared_Path_Matrix = SharedArray{Path{N},2}(nrow,ncol)
    for i = 1:nrow
        for j = 1:ncol
            if M[i,j] != 0
                o = M[i,j][1]
                d = M[i,j][end]
                p = Tuple(M[i,j])
                Shared_Path_Matrix[i,j] = Path(o,d,p)
            end
        end
    end

    Routing_Table = Store_Path_Matrix(Routing_Table,Shared_Path_Matrix)

    return Shared_Path_Matrix,Routing_Table
end


# Counting total number of zero in the Routing_Table
# @param Shared_Path_Matrix: The matrix include path info. between two nodes.
# @return sum: total number of zero
function count_zero(Shared_Path_Matrix)
    sum = 0
    n,m = size(Shared_Path_Matrix)
    for i = 1:n
        for j = 1:m
            if Shared_Path_Matrix[i,j].o == 0
                sum = sum + 1
            end
        end
    end
    return sum
end

# Shared LM method iteration method
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
# @return iter: number of iteration
function Shared_Iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    Shared_Link_Matrix = Convert_Data_Structure(connectMatrix)
    Shared_Path_Matrix = Shared_Link_Matrix
    Routing_Table = Creat_Routing_Table(Shared_Link_Matrix)

    n,m = size(Shared_Path_Matrix)
    flag = n * m
    iter = 0
    sum = count_zero(Shared_Path_Matrix)

    while sum != flag
        Shared_Path_Matrix,Routing_Table = Shared_LM_Method(Shared_Path_Matrix,Shared_Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)
        iter = iter + 1
        sum = count_zero(Shared_Path_Matrix)
    end
    return Routing_Table,iter
end

# Counting all path based on routing table
# @param Routing_Table: the routing table
# @return sum: total number of path
function count_all(Routing_Table)
    m,n = size(Routing_Table)
    sum  = 0
    Path_Vec = []
    for i = 1:m
        for j = 1:n
            l = length(Routing_Table[i,j])
            sum = sum + l
            if l != 0
                for p = 1:l
                    push!(Path_Vec,Routing_Table[i,j][p])
                end
            end
        end
    end
    #return sum,Path_Vec
    return sum
end

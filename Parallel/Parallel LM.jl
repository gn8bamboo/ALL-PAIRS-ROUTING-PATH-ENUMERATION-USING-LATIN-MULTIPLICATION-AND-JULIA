# The LM method
# @param Path_Matrix: The matrix include path info. between two nodes.
# @param Link_Matrix: contains the adjacent links of the topology
#          and does not change throughoutthe simulation process
# @param Routing_Table: Routing Table
# @return res: all possible path between two nodes
# @cite: M. Gondran and M. Minoux, Graphs, Dioids and Semirings: New Models and Algorithms
function LM_Method(Path_Matrix,Link_Matrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    nrow,ncol = size(Path_Matrix)
    res = Matrix(undef,nrow,ncol)
    fill!(res,0)

    for i = 1:nrow
        for j = 1:ncol
            for k = 1:ncol
                if Path_Matrix[i,j] != 0 && Link_Matrix[j,k]!=0
                    X = Path_Matrix[i,j]
                    Y = Link_Matrix[j,k][2:end]
                    Potential_Path = [X;Y]
                    Passed_Path = Path_Validator(Potential_Path,relationshipMatrix)
                    if Passed_Path != []
                        if res[i,k] == 0
                            res[i,k] = Potential_Path
                        else
                            Current_Path = res[i,k]
                            Prefer_Path = Business_Policy(Current_Path,Potential_Path,ISP_Local_Preference,ISP_Location)
                            res[i,k] = Prefer_Path
                        end
                    end
                end
            end
        end
    end
    #Path_Matrix = res
    #Routing_Table = Store_Path_Matrix(Routing_Table,Path_Matrix)
    #return Path_Matrix,Routing_Table

    return res
end

# Parallize Latin_Multiplication function
# @param Path_Matrix The matrix include path info. between two nodes.
# @param Link_Matrix contains the adjacent links of the topology
#          and does not change throughoutthe simulation process
# @param Routing_Table Routing Table
# @return Routing_Table Routing Table
# @return Path_Matrix The matrix include path info. between two nodes.
function Parallel_LM_Method(Path_Matrix,Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    res = Vector(undef,nworkers())
    nchunks = length(workers())
    n = size(Link_Matrix)[1]

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
            Sub_Path_Matrix = Path_Matrix[spiltrange[idx],:]
            @async res[idx] = fetch(remotecall_wait(LM_Method,pid,Sub_Path_Matrix,Link_Matrix,relationshipMatrix,ISP_Local_Preference,ISP_Location))
        end


        M = Matrix(undef,n,n)
        fill!(M,0)

        for (idx, pid) in enumerate(workers())
            M[spiltrange[idx],:] = res[idx]
        end

        Path_Matrix = M
        Routing_Table = Store_Path_Matrix(Routing_Table,Path_Matrix)

        return Path_Matrix,Routing_Table
end



# LM method iteration method
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
# @return iter: number of iteration
function Para_Iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    Link_Matrix = Convert_Data_Structure(connectMatrix)
    Path_Matrix = Link_Matrix
    Routing_Table = Creat_Routing_Table(connectMatrix)

    #n = count(iszero, Path_Matrix)
    #N = size(Path_Matrix)[1]

    n,m = size(Path_Matrix)
    flag = n * m
    iter = 0

    while count(x -> x == 0,Path_Matrix) != flag
        Path_Matrix,Routing_Table = Parallel_LM_Method(Path_Matrix,Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)
        iter = iter + 1
    end
    return Routing_Table,iter
end

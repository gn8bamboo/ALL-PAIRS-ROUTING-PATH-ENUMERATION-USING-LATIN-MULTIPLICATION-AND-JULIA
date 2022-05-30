# Convert data structure from adjacency matrix to Link matrix
# @param connectMatrix: the adjacency matrix
# @return Link_Matrix: the adjacency link between two nodes
function Convert_Data_Structure(connectMatrix)
    nrow,ncol = size(connectMatrix)
    Link_Matrix = Matrix(undef,nrow,ncol)

    for i = 1:nrow
        for j = 1:ncol
            if connectMatrix[i,j] != 0
                Link_Matrix[i,j] = [i,j]
            else
                Link_Matrix[i,j] = 0
            end
        end
    end
    return Link_Matrix
end

# Build routing table based on the adjacency matrix
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
function Creat_Routing_Table(connectMatrix)
    nrow,ncol = size(connectMatrix)
    Routing_Table = Matrix(undef,nrow,ncol)
    fill!(Routing_Table,0)

    for i = 1:nrow
        for j = 1:ncol
            Routing_Table[i,j] = Vector()
            if connectMatrix[i,j] != 0
                push!(Routing_Table[i,j],[i,j])
            end
        end
    end

    return Routing_Table
end

# Store result to routing table
# @param Path_Matrix: all possible path between two nodes
# @param Routing_Table: the routing table
# @return Routing_Table: the routing table
function Store_Path_Matrix(Routing_Table,Path_Matrix)
    nrow,ncol = size(Path_Matrix)
    for i = 1:nrow
        for j = 1:ncol
            if Path_Matrix[i,j] != 0
                if typeof(Path_Matrix[i,j]) == Array{Int64,1}
                    push!(Routing_Table[i,j],Path_Matrix[i,j])
                else
                    for p = 1:length(Path_Matrix[i,j])
                        push!(Routing_Table[i,j],Path_Matrix[i,j][p])
                    end
                end
            end
        end
    end

    return Routing_Table
end

# The LM method
# @param Path_Matrix: all possible path between two nodes
# @param Link_Matrix: the adjacency link between two nodes
# @param Routing_Table: the routing table
# @return Path_Matrix: all possible path between two nodes
# @return Routing_Table: the routing table
# @cite: M. Gondran and M. Minoux, Graphs, Dioids and Semirings: New Models and Algorithms
function LM_Method(Path_Matrix,Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)

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
    Path_Matrix = res
    Routing_Table = Store_Path_Matrix(Routing_Table,Path_Matrix)
    return Path_Matrix,Routing_Table
end

# LM method iteration method
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
# @return iter: number of iteration
function iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    Link_Matrix = Convert_Data_Structure(connectMatrix)
    Path_Matrix = Link_Matrix
    Routing_Table = Creat_Routing_Table(connectMatrix)

    #n = count(iszero, Path_Matrix)
    #N = size(Path_Matrix)[1]

    n,m = size(Path_Matrix)
    flag = n * m
    iter = 0

    while count(x -> x == 0,Path_Matrix) != flag
        Path_Matrix,Routing_Table = LM_Method(Path_Matrix,Link_Matrix,Routing_Table,relationshipMatrix,ISP_Local_Preference,ISP_Location)
        iter = iter + 1
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

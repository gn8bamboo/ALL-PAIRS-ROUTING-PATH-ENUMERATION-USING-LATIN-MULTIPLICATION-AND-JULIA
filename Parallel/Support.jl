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


# Counting all path based on routing table
# @param Routing_Table: the routing table
# @return sum: number of path
# @return Path_Vec: routing vector
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

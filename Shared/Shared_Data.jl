# New data struct Path used in shared array
@everywhere struct Path{N}
    o::Int64
    d::Int64
    p::NTuple{N,Int64}
end

# Convert data structure from adjacency matrix to Link matrix
# @param connectMatrix: the adjacency matrix
# @return Shared_Link_Matrix: the adjacency link between two nodes
function Convert_Data_Structure(connectMatrix)
    nrow,ncol = size(connectMatrix)
    Shared_Link_Matrix = SharedArray{Path{2},2}(nrow,ncol)

    for i = 1:nrow
        for j = 1:ncol
            if connectMatrix[i,j] != 0
                Shared_Link_Matrix[i,j] = Path(i,j,(i,j))
            end
        end
    end
    return Shared_Link_Matrix
end

# Build routing table based on the Shared_Link_Matrix
# @param Shared_Link_Matrix: the adjacency link between two nodes
# @return Routing_Table: the routing table
function Creat_Routing_Table(Shared_Link_Matrix)
    nrow,ncol = size(Shared_Link_Matrix)
    Routing_Table = Matrix(undef,nrow,ncol)
    fill!(Routing_Table,0)

    for i = 1:nrow
        for j = 1:ncol
            Routing_Table[i,j] = Vector()
            if Shared_Link_Matrix[i,j].o != 0 && Shared_Link_Matrix[i,j].d != 0
                push!(Routing_Table[i,j],collect(Shared_Link_Matrix[i,j].p))
            end
        end
    end

    return Routing_Table
end

# Store result to routing table
# @param Shared_Path_Matrix: all possible path between two nodes
# @param Routing_Table: the routing table
# @return Routing_Table: the routing table
function Store_Path_Matrix(Routing_Table,Shared_Path_Matrix)
    nrow,ncol = size(Shared_Path_Matrix)
    for i = 1:nrow
        for j = 1:ncol
            if Shared_Path_Matrix[i,j].o != 0 && Shared_Path_Matrix[i,j].d != 0
                    push!(Routing_Table[i,j],collect(Shared_Path_Matrix[i,j].p))
            end
        end
    end

    return Routing_Table
end

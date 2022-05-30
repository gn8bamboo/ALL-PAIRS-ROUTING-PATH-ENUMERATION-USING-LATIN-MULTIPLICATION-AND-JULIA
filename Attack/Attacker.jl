
function Random_Pretend(Attack,ispn)

    n = ispn

    if Attack == 1
        random_pretend = rand(2:n)
    elseif Attack == n
        random_pretend = rand(1:n-1)
    else
        F = collect(1:Attack-1)
        L = collect(Attack+1:n)
        random_range = vcat(F,L)
        random_pretend = rand(random_range)
    end
    Pretend = random_pretend
    return Pretend
end

# Creating new Path_Matrix with path prefix attack with attack AS and pretend AS
# @param Path_Matrix: Path_Matrix: all possible path between two nodes
# @param Attack: attack AS
# @param Pretend: pretend AS
# @return New_Path_Matrix: Path_Matrix with path prefix attack
function Attack_Path_Matrix(Path_Matrix,Attack,Pretend)
    m,n = size(Path_Matrix)
    F = collect(1:Attack-1)
    L = collect(Attack+1:m)
    looprange = vcat(F,L)

    New_Path_Matrix = Matrix(undef,m,n)
    fill!(New_Path_Matrix,0)

    for i in looprange
        if Path_Matrix[i,Attack] != 0
            New_Path_Matrix[i,Pretend] = Path_Matrix[i,Attack]
        end
    end

    return New_Path_Matrix
end

# Build routing table based on the New_Path_Matrix
# @param New_Path_Matrix: Path_Matrix with path prefix attack
# @return Attack_Routing_Table: the routing table
function Creat_Attack_Routing_Table(New_Path_Matrix)
    nrow,ncol = size(New_Path_Matrix)
    Attack_Routing_Table = Matrix(undef,nrow,ncol)
    fill!(Attack_Routing_Table,0)

    for i = 1:nrow
        for j = 1:ncol
            Attack_Routing_Table[i,j] = Vector()
            if New_Path_Matrix[i,j] != 0
                push!(Attack_Routing_Table[i,j],New_Path_Matrix[i,j])
            end
        end
    end

    return Attack_Routing_Table
end

# Attack LM method iteration method
# @param connectMatrix: the adjacency matrix
# @return Routing_Table: the routing table
# @return iter: number of iteration
function Attack_iter(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location,Attack,Pretend)
    Link_Matrix = Convert_Data_Structure(connectMatrix)
    Path_Matrix = Link_Matrix
    New_Path_Matrix = Attack_Path_Matrix(Path_Matrix,Attack,Pretend)
    ART = Creat_Attack_Routing_Table(New_Path_Matrix)
    nn = count_all(ART)

    n,m = size(New_Path_Matrix)
    flag = n * m

    while count(x -> x == 0,New_Path_Matrix) != flag
        New_Path_Matrix,ART = LM_Method(New_Path_Matrix,Link_Matrix,ART,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    end

    return ART,nn
end

# list attack result in DataFrame
function Attack_Result(ispn,RT,connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)

    nwithout = count_all(RT)
    attact_res = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])
    flag = "No"
    for i = 1:ispn
        F = collect(1:i-1)
        L = collect(i+1:ispn)
        looprange = vcat(F,L)
        for j in looprange
            (ART,nn), t, bytes, gctime, memallocs = @timed Attack_iter(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location,i,j)
            nwith = count_all(ART) - nn

            if nwith == 0
                flag = "No"
            else
                flag = "Yes"
            end

            attact_res = vcat(attact_res, DataFrame(Attack_AS = i, Pretend_AS = j,
                                Pretend_Successful_Path = nn, Total_Path = nwithout + nwith,
                                Attack_Successful_Path = nwith, Attack_Successful = flag,
                                Elapsed_Time = t))

        end
    end

    return nwithout,attact_res
end

# attack result statistics result in DataFrame
function res_stat(df,nTier_1,nTier_X,nStubs,ispn)

    Tier_1_range = 1:nTier_1
    Tier_X_range = nTier_1 + 1:nTier_1 + nTier_X
    Stubs_range = nTier_1 + nTier_X + 1 : ispn

    Tier_1_att = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    Tier_X_att = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])


    Stubs_att = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])


    for i in Tier_1_range
        temp = filter(x -> x.Attack_AS == i,df)
        append!(Tier_1_att,temp)
    end

    for i in Tier_X_range
        temp = filter(x -> x.Attack_AS == i,df)
        append!(Tier_X_att,temp)
    end

    for i in Stubs_range
        temp = filter(x -> x.Attack_AS == i,df)
        append!(Stubs_att,temp)
    end

    return Tier_1_att, Tier_X_att, Stubs_att
end

# tier-1 attack result statistics result in DataFrame
function Tier_1_stat(Tier_1_att,nTier_1,nTier_X,nStubs,ispn)
    Tier_1_range = 1:nTier_1
    Tier_X_range = nTier_1 + 1:nTier_1 + nTier_X
    Stubs_range = nTier_1 + nTier_X + 1 : ispn

    Tier_1_att_Tier_X = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    Tier_1_att_Stubs = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    for i in Tier_X_range
        temp = filter(x -> x.Pretend_AS == i,Tier_1_att)
        append!(Tier_1_att_Tier_X,temp)
    end

    for i in Stubs_range
        temp = filter(x -> x.Pretend_AS == i,Tier_1_att)
        append!(Tier_1_att_Stubs,temp)
    end

    return Tier_1_att_Tier_X, Tier_1_att_Stubs
end

# tier-x attack result statistics result in DataFrame
function Tier_X_stat(Tier_X_att,nTier_1,nTier_X,nStubs,ispn)
    Tier_1_range = 1:nTier_1
    Tier_X_range = nTier_1 + 1:nTier_1 + nTier_X
    Stubs_range = nTier_1 + nTier_X + 1 : ispn

    Tier_X_att_Tier_1 = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    Tier_X_att_Stubs = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    for i in Tier_1_range
        temp = filter(x -> x.Pretend_AS == i,Tier_X_att)
        append!(Tier_X_att_Tier_1,temp)
    end

    for i in Stubs_range
        temp = filter(x -> x.Pretend_AS == i,Tier_X_att)
        append!(Tier_X_att_Stubs,temp)
    end

    return Tier_X_att_Tier_1, Tier_X_att_Stubs
end

# stubs attack result statistics result in DataFrame
function Stubs_stat(Stubs_att,nTier_1,nTier_X,nStubs,ispn)
    Tier_1_range = 1:nTier_1
    Tier_X_range = nTier_1 + 1:nTier_1 + nTier_X
    Stubs_range = nTier_1 + nTier_X + 1 : ispn

    Stubs_att_Tier_1 = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    Stubs_att_Tier_X = DataFrame(Attack_AS = Int64[], Pretend_AS = Int64[],
                            Pretend_Successful_Path = Int64[] ,Total_Path = Int64[],
                            Attack_Successful_Path = Int64[], Attack_Successful = String[],
                            Elapsed_Time = Float64[])

    for i in Tier_1_range
        temp = filter(x -> x.Pretend_AS == i,Stubs_att)
        append!(Stubs_att_Tier_1,temp)
    end

    for i in Tier_X_range
        temp = filter(x -> x.Pretend_AS == i,Stubs_att)
        append!(Stubs_att_Tier_X,temp)
    end

    return Stubs_att_Tier_1, Stubs_att_Tier_X
end

using Distributed
#addprocs(4)

@everywhere using Glob
@everywhere using TimerOutputs
@everywhere using Dates
@everywhere using DataFrames



to = TimerOutput()
@timeit to "Parallel LM Method Router Level Simulation" begin
    @timeit to "Initialization" include("Para_Router_Initialization.jl")
    @timeit to "Router Enumeration" RT,iter,Single_Pair_RT,Multi_Pair_RT = Router_Level_Simulation(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location,ispn,Single_RMatrix,Multi_RMatrix)
    @timeit to "Counting Path" n = count_all(RT)
    @timeit to "Router_View" begin
        @timeit to "Single Pair" df1 = Router_Policy(RT,Single_Pair_RT,ISP_Router_Location,1,3)
        @timeit to "Multiple Pair" df2 = Router_Policy(RT,Multi_Pair_RT,ISP_Router_Location,1,3)
        end
end

nn = nworkers()
date = now()
filename = "Parallel_Router_Log.txt"
f=open(filename,"a")
println(f,"Parallel LM Method Router Level Simulation on Raj")
println(f, "Date: $date");
println(f, "Network Size: $ispn");
println(f, "Number of Workers: $nn");
println(f, "Number of LM iteration: $iter");
println(f, "Number of Path: $n")
println(f,to)
println(f,"\n")
close(f)

Print_Router_Policy(df1,filename)
Print_Router_Policy(df2,filename)

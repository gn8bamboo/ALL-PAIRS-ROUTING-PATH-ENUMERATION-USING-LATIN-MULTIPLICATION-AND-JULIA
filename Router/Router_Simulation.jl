
using Glob
using Dates
using DataFrames
using TimerOutputs

to = TimerOutput()
@timeit to "LM Method Router Level Simulation" begin
    @timeit to "Initialization" include("Router_Initialization.jl")
    @timeit to "Path Enumeration" RT,iter,Single_Pair_RT,Multi_Pair_RT = Router_Level_Simulation(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location,ispn,Single_RMatrix,Multi_RMatrix)
    @timeit to "Counting Path" n = count_all(RT)
    @timeit to "Router_View" begin
        @timeit to "Single Pair" df1 = Router_Policy(RT,Single_Pair_RT,ISP_Router_Location,o,d)
        @timeit to "Multiple Pair" df2 = Router_Policy(RT,Multi_Pair_RT,ISP_Router_Location,o,d)
        end
end

date = now()
filename = "Router_Log.txt"
f=open(filename,"a")
println(f,"Latin Multiplication Method Result on Local")
println(f, "Date: $date");
println(f, "Network Size: $ispn");
println(f, "Number of LM iteration: $iter");
println(f, "Number of Path: $n")
println(f,to)
println(f,"\n")
close(f)
Print_Router_Policy(df1,filename)
Print_Router_Policy(df2,filename)

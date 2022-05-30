
using Glob
using Dates
using TimerOutputs


to = TimerOutput()
@timeit to "LM Method AS Level Simulation" begin
    @timeit to "Initialization" include("AS_Initialization.jl")
    @timeit to "Path Enumeration" RT,iter = iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    @timeit to "Counting Path" n = count_all(RT)
end

date = now()
logname = "AS_Log.txt"
f=open(logname,"a")
println(f,"Latin Multiplication Method Result on Local")
println(f, "Date: $date");
println(f, "Network Size: $ispn");
println(f, "Number of LM iteration: $iter");
println(f, "Number of Path: $n")
println(f,to)
println(f,"\n")
close(f)

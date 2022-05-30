using Distributed
#addprocs(2)

@everywhere using SharedArrays
@everywhere using Glob
@everywhere using TimerOutputs
@everywhere using Dates



to = TimerOutput()
@timeit to "Shared-Array LM Method" begin
    @timeit to "Initialization" include("Shared_Initialization.jl")
    @timeit to "Path Enumeration" RT,iter = Shared_Iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    @timeit to "Counting Path" n = count_all(RT)
end

 nn = nworkers()
 date = now()
 logname = "Shared_Log.txt"
 f=open(logname,"a")
 println(f,"Shared-Array Latin Multiplication Method Result on Local")
 println(f, "Date: $date");
 println(f, "Number of Workers: $nn");
 println(f, "Network Size: $ispn");
 println(f, "Number of LM iteration: $iter");
 println(f, "Number of Path: $n")
 println(f,to)
 println(f,"\n")
 close(f)

using Distributed
#addprocs(4)
#addprocs(8)
#addprocs(16)
#addprocs(32)

@everywhere using Glob
@everywhere using TimerOutputs
@everywhere using Dates


to = TimerOutput()
@timeit to "Parallel LM Method" begin
    @timeit to "Initialization" include("Para_Initialization.jl")
    @timeit to "Path Enumeration" RT,iter = Para_Iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    @timeit to "Counting Path" n = count_all(RT)
end

 nn = nworkers()
 date = now()
 logname = "Parallel_Log.txt"
 f=open(logname,"a")
 println(f,"Parallel Latin Multiplication Method Result on Local")
 println(f, "Date: $date");
 println(f, "Number of Workers: $nn");
 println(f, "Network Size: $ispn");
 println(f, "Number of LM iteration: $iter");
 println(f, "Number of Path: $n")
 println(f,to)
 println(f,"\n")
 close(f)

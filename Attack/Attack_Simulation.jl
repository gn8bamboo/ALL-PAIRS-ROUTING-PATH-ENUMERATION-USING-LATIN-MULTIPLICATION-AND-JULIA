
using Glob
using Dates
using DataFrames
using TimerOutputs


to = TimerOutput()
@timeit to "If One AS Pretend as Another AS" begin
    @timeit to "Initialization" include("Attack_Initialization.jl")
    @timeit to "Path Enumeration" RT,iter = iteration(connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    @timeit to "Attack Process" nwithout,df = Attack_Result(ispn,RT,connectMatrix,relationshipMatrix,ISP_Local_Preference,ISP_Location)
    @timeit to "Stat Process" include("Stat.jl")
end

date = now()
total_attack = size(df)[1]
countatt = length(findall( x -> x == "Yes", df.Attack_Successful))
logname = "Attack_Log.txt"
f=open(logname,"a")
println(f,"Latin Multiplication Method Result Without Attacker")
println(f, "Date: $date");
println(f, "Network Size: $ispn");
println(f, "Number of LM iteration: $iter");
println(f, "Number of Path: $nwithout")
println(f,to)
println(f,"\n")
println(f,"Latin Multiplication Method Result With Attacker")
println(f, "Network Size: $ispn");
println(f, "Total of Attack : $total_attack ");
println(f, "Attack Successful : $countatt ");
println(f,"Attack Successful Percentage: $(countatt/total_attack) ");
println(f,df)
println(f,"\n")
close(f)

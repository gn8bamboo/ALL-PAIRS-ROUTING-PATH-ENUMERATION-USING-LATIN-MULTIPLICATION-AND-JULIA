
Tier_1_att, Tier_X_att, Stubs_att = res_stat(df,nTier_1,nTier_X,nStubs,ispn)


Tier_1_att_Tier_X, Tier_1_att_Stubs = Tier_1_stat(Tier_1_att,nTier_1,nTier_X,nStubs,ispn)



Tier_X_att_Tier_1, Tier_X_att_Stubs = Tier_X_stat(Tier_X_att,nTier_1,nTier_X,nStubs,ispn)


Stubs_att_Tier_1, Stubs_att_Tier_X = Stubs_stat(Stubs_att,nTier_1,nTier_X,nStubs,ispn)

res = DataFrame(Name = String[],Total_Attack = Int64[],
                Attack_Successful = Int64[], Attack_Successful_Percentage = Float64[])

T1_total = size(Tier_1_att)[1]
T1_Successful = length(findall( x -> x == "Yes", Tier_1_att.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_1 Attack",
                        Total_Attack = T1_total,
                        Attack_Successful = T1_Successful,
                        Attack_Successful_Percentage = T1_Successful/T1_total))

TX_total = size(Tier_X_att)[1]
TX_Successful = length(findall( x -> x == "Yes", Tier_X_att.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_X Attack",
                        Total_Attack = TX_total,
                        Attack_Successful = TX_Successful,
                        Attack_Successful_Percentage = TX_Successful/TX_total))

Stubs_total = size(Stubs_att)[1]
Stubs_Successful = length(findall( x -> x == "Yes", Stubs_att.Attack_Successful))
res = vcat(res, DataFrame(Name = "Stubs_att Attack",
                        Total_Attack = Stubs_total,
                        Attack_Successful = Stubs_Successful,
                        Attack_Successful_Percentage = Stubs_Successful/Stubs_total))

T1_TX_total = size(Tier_1_att_Tier_X)[1]
T1_TX_Successful = length(findall( x -> x == "Yes", Tier_1_att_Tier_X.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_1 Attack Tier_X",
                        Total_Attack = T1_TX_total,
                        Attack_Successful = T1_TX_Successful,
                        Attack_Successful_Percentage = T1_TX_Successful/T1_TX_total))

T1_Stubs_total = size(Tier_1_att_Stubs)[1]
T1_Stubs_Successful = length(findall( x -> x == "Yes", Tier_1_att_Stubs.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_1 Attack Stubs",
                        Total_Attack = T1_Stubs_total,
                        Attack_Successful = T1_Stubs_Successful,
                        Attack_Successful_Percentage = T1_Stubs_Successful/T1_Stubs_total))

TX_T1_total = size(Tier_X_att_Tier_1)[1]
TX_T1_Successful = length(findall( x -> x == "Yes", Tier_X_att_Tier_1.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_X Attack Tier_1",
                        Total_Attack = TX_T1_total,
                        Attack_Successful = TX_T1_Successful,
                        Attack_Successful_Percentage = TX_T1_Successful/TX_T1_total))

TX_Stubs_total = size(Tier_X_att_Stubs)[1]
TX_Stubs_Successful = length(findall( x -> x == "Yes", Tier_X_att_Stubs.Attack_Successful))
res = vcat(res, DataFrame(Name = "Tier_X Attack Stubs",
                        Total_Attack = TX_Stubs_total,
                        Attack_Successful = TX_Stubs_Successful,
                        Attack_Successful_Percentage = TX_Stubs_Successful/TX_Stubs_total))

Stubs_T1_total =  size(Stubs_att_Tier_1)[1]
Stubs_T1_Successful = length(findall( x -> x == "Yes", Stubs_att_Tier_1.Attack_Successful))
res = vcat(res, DataFrame(Name = "Stubs Attack Tier_1",
                        Total_Attack = Stubs_T1_total,
                        Attack_Successful = Stubs_T1_Successful,
                        Attack_Successful_Percentage = Stubs_T1_Successful/Stubs_T1_total))

Stubs_TX_total =  size(Stubs_att_Tier_X)[1]
Stubs_TX_Successful = length(findall( x -> x == "Yes", Stubs_att_Tier_X.Attack_Successful))
res = vcat(res, DataFrame(Name = "Stubs Attack Tier_X",
                        Total_Attack = Stubs_TX_total,
                        Attack_Successful = Stubs_TX_Successful,
                        Attack_Successful_Percentage = Stubs_TX_Successful/Stubs_TX_total))



date = now()
logname = "Attack_Stats.txt"
f=open(logname,"a")
println(f,"Attack Statistics Result")
println(f, "Date: $date");
println(f, "Network Size: $ispn");
println(f,res)
println(f,"\n")
close(f)

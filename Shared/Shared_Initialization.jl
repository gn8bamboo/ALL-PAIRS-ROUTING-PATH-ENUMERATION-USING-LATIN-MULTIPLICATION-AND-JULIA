
@everywhere include("/Users/bamboo/Desktop/LM/Utilities/Geo.jl")
@everywhere include("/Users/bamboo/Desktop/LM/Utilities/Read.jl")
@everywhere include("/Users/bamboo/Desktop/LM/Utilities/Patterns_Rule.jl")
@everywhere include("/Users/bamboo/Desktop/LM/Utilities/Bussiness_Policy.jl")
@everywhere include("/Users/bamboo/Desktop/LM/Shared/Shared_Data.jl")
@everywhere include("/Users/bamboo/Desktop/LM/Shared/Shared_LM.jl")


###################################VARIABLE MAP##################################
# path: Location of Network Model
# Connpath: Location of file with statistics of the connectionsbetween ASes.
# Adjpath: Location of Adjacency Matrix of Network
# ISPpath: Location of file with xy location of each ISP.
# ispn: total number of ISPs (Tier-1,Tier-x,stubs)
# nTier_1: number of Tier-1
# nTier_X: number of ier_X
# nStubs: number of Stubs
# nPoPs: number of PoPs
# connectMatrix: connection matrix
# relationshipMatrix: relationships matrix
# ISP_Location: XY location of ISP on map(network)
# ISP_Local_Preference: local preference value for each ISP
#################################################################################


path = "/Users/bamboo/Desktop/LM/Network"
Connpath,Adjpath,ISPpath = ReadPath(path)
ispn,nTier_1,nTier_X,nStubs,nPoPs = ReadBasic(Connpath)
connectMatrix,relationshipMatrix = ReadAdjMatrix(Adjpath,ispn,nPoPs)
ISP_Location = ReadISP(ISPpath)
ISP_Local_Preference = Set_Local_Preference(ispn,nTier_1,nTier_X)

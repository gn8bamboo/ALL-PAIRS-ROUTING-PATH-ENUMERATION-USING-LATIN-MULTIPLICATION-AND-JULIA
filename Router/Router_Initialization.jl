
include("/Users/bamboo/Desktop/LM/Utilities/Geo.jl")

include("/Users/bamboo/Desktop/LM/Utilities/Read.jl")
include("/Users/bamboo/Desktop/LM/Utilities/LM_Method.jl")
include("/Users/bamboo/Desktop/LM/Utilities/Patterns_Rule.jl")
include("/Users/bamboo/Desktop/LM/Utilities/Bussiness_Policy.jl")

include("/Users/bamboo/Desktop/LM/Router/Router.jl")
include("/Users/bamboo/Desktop/LM/Router/Router_Policy.jl")


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
# ISP_Router_Location: XY location of router on map(network)
# Single_RMatrix: single pair the routing table
# Multi_RMatrix: multi pair the routing table
#################################################################################


path = "/Users/bamboo/Desktop/LM/Network"
#path = "/users/home/hsun18/Network"
Connpath,Adjpath,ISPpath = ReadPath(path)
ispn,nTier_1,nTier_X,nStubs,nPoPs = ReadBasic(Connpath)
connectMatrix,relationshipMatrix = ReadAdjMatrix(Adjpath,ispn,nPoPs)
ISP_Location = ReadISP(ISPpath)
ISP_Local_Preference = Set_Local_Preference(ispn,nTier_1,nTier_X)

ISP_Router_Location = Fixed_Set_Routers(ISP_Location,ispn,nTier_1,nTier_X)
Single_RMatrix = Border_Router_Single(ISP_Router_Location)
Multi_RMatrix = Border_Router_Multi(ISP_Router_Location)

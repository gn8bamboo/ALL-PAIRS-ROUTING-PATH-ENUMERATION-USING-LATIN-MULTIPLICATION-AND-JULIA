# Read Connect Stats.txt file to get basic info. about the model
# @param Connpath: Connpath Location of Connect Stats.txt file
# @return ispn: total number of ISPs (Tier-1,Tier-x,stubs)
# @return nTier_1: # of Tier-1 ISPs
# @return nTier_X: # of Tier-X ISPs
# @return nStubs: # of Stubs ISPs
function ReadBasic(Connpath)
  stream = open(Connpath,"r")
  strinfo = readlines(stream)
  close(stream)

  nTier_1 = parse(Int, split(strinfo[3]," : ")[2])
  nTier_X = parse(Int, split(strinfo[4]," : ")[2])
  nStubs = parse(Int, split(strinfo[5]," : ")[2])
  nPoPs = parse(Int, split(strinfo[6]," : ")[2])

  ispn = nTier_1 + nTier_X + nStubs

  return ispn,nTier_1,nTier_X,nStubs,nPoPs
end

# Read AdjMatrix.txt file to get connection and relationship info.
# @param Adjpath: Location of AdjMatrix.txt file
# @param ispn: total number of ISPs (Tier-1,Tier-x,stubs)
# @param nPoPs: # of PoPs
# @returns connectMatrix: Each matrix element indicates whether two ASes
#                        have a connection at a specific PoPs.
# @returns relationshipMatrix: Each matrix element indicates business relationship
#                             between two nodes.
function ReadAdjMatrix(Adjpath,ispn,nPoPs)
  stream = open(Adjpath,"r")
  strinfo = readlines(stream)
  close(stream)
  size = length(strinfo)

  connectMatrix = Matrix(undef,ispn,ispn)
  fill!(connectMatrix, 0)
  relationshipMatrix = Matrix(undef,ispn,ispn)
  fill!(relationshipMatrix, 0)

  for i = 1:size
    #Basic info.
    temp = split(strinfo[i]," : ")
    temp1 = split(temp[1],",")
    temp2 = split(temp[end])
    #Connection
    temp_org = parse(Int64,temp1[1])
    temp_des = parse(Int64,temp1[2])
    temp_pop = parse(Int64,temp1[3])
    #Type
    temp_type = parse(Int64,temp2[1])

    connectMatrix[temp_org,temp_des] = temp_pop
    relationshipMatrix[temp_org,temp_des] = temp_type
  end

  #connectMatrix = LowerTriangular(connectMatrix)
  #relationshipMatrix = LowerTriangular(relationshipMatrix)
  return connectMatrix,relationshipMatrix
end

# Read Network Model Path, get location of Connect Stats.txt file and AdjMatrix.txt file
# @param path: Location of Network Model
# @return Connpath: Location of Connect Stats.txt file
# @return Adjpath: Location of AdjMatrix.txt file
# @return ISPpath: Location of ISP-Details.txt file
function ReadPath(path)
  folderlist = glob("project*",path)
  base = folderlist[end]
  filelist = glob("Ellipse*",base)

  Connpath = joinpath(filelist[end],"Connection Stats.txt")
  Adjpath = joinpath(filelist[end],"AdjMatrix.txt")
  ISPpath = joinpath(filelist[end],"ISP-Details.txt")

  return Connpath,Adjpath,ISPpath
end

# Read Network Model Path, get location of Connect Stats.txt file and AdjMatrix.txt file
# @param ISPpath: Location of ISP-Details.txt file
# @return ISP: XY Location of each ISP om map(network)
function ReadISP(ISPpath)
  stream = open(ISPpath,"r")
  strinfo = readlines(stream)
  close(stream)
  size = length(strinfo)
  ISP = Vector()

  for i = 1:size
    E = rand(Ellipse)
    temp = split(strinfo[i],"{Float64}(")
    temp1 = split(temp[end],"),")
    ecenter = split(temp1[1],",")
    x = parse(Float64,ecenter[1])
    y = parse(Float64,ecenter[end])

    axis = split(temp1[2],",")
    rx =  parse(Float64,axis[1])
    ry =  parse(Float64,axis[2])
    th = parse(Float64,axis[3][1:end-1])

    E.center.x = x
    E.center.y = y
    E.a = rx
    E.b = ry
    E.theta = th
    push!(ISP,E)
  end

  return ISP
end

###################################VARIABLE MAP##################################
# o <Origin AS> Default 1
# d <Destination AS> Default 2
# T <Simulation Type>
#   T G <General LM Method in AS level>
#   T P <Parallel LM Method in AS level>
#   T S <SharedArray LM Method in AS level>
#   T R <Router Level Simulation with General LM Method>
#   T A <If one AS pretend as another AS>
#################################################################################

#check that all required arguments are present.
function argumentchecks(args)
    error = false
    if in("-?",args)
        println("Command Arguments :")
        println("-T <Simulation Type>")
        println("-? <Help page>")
        println("Optional :")
        println("-o <Origin AS> Default 1")
        println("-d <Destination AS> Default 2")
        println("Simulation Type Info :")
        println("-T G <General LM Method in AS level>")
        println("-T P <Parallel LM Method in AS level>")
        println("-T S <SharedArray LM Method in AS level>")
        println("-T R <Router Level Simulation with General LM Method>")
        #println("-T PR <Parallel Router Level Simulation with General LM Method>")
        println("-T A <If one AS pretend as another AS>")
        exit(0)
    end

    ind = findall(x->x=="-T",args)
    if isempty(ind) || length(ind) > 1
      println(" Error reading -T value")
      error = trues
    else
      T = args[ind[1]+1]
    end

    ind = findall(x->x=="-o",args)
    if isempty(ind)
        o = 1
    elseif length(ind) > 1
        println(" Error reading -o value")
        error = trues
    else
        o = parse(Int64,args[ind[1]+1])
    end

    ind = findall(x->x=="-d",args)
    if isempty(ind)
        d = 2
    elseif length(ind) > 1
        println(" Error reading -d value")
        error = trues
    else
        d = parse(Int64,args[ind[1]+1])
    end

    if error
        println("Command Arguments :")
        println("-T <Simulation Type>")
        println("-? <Help page>")
        println("Optional :")
        println("-o <Origin AS> Default 1")
        println("-d <Destination AS> Default 2")
        println("Simulation Type Info :")
        println("-T G <General LM Method in AS level>")
        println("-T P <Parallel LM Method in AS level>")
        println("-T S <SharedArray LM Method in AS level>")
        println("-T R <Router Level Simulation with General LM Method>")
        println("-T A <If one AS pretend as another AS>")
        exit(-1)
    else
        return T,o,d
    end
    println("Arguments are correct")
end

#check that all required arguments are present.
T,o,d = argumentchecks(ARGS)

if T == "G"
    include("AS/AS_Simulation.jl")
end
if T == "R"
    include("Router/Router_Simulation.jl")
end
if T == "A"
    include("Attack/Attack_Simulation.jl")
end
if T == "P"
    include("Parallel/Para_Simulation.jl")
end
if T == "S"
    include("Shared/Shared_Simulation.jl")
end

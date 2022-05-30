# ALL-PAIRS-ROUTING-PATH-ENUMERATION-USING-LATIN-MULTIPLICATION-AND-JULIA

Enumerating all routing paths among Autonomous Systems (ASes) at an Internetscale is an intractable problem. The Border Gateway Protocol (BGP) is the standard exterior gateway protocol through which ASes exchange reachability information. Building an efficient path enumeration tool for a given network is an essential step towards estimating the resiliency of the network to cyber security attacks, such as routing origin and path hijacking. In our work, we use the matrix Latin multiplication method to compute all possible paths among all pairs of nodes. We parallelize this computation through the domain decomposition for matrix multiplication and implement our solution in the Julia high performance programming language. We also compare our method with classical Monte Carlo method. Our results provide positive evidence for the applicability of the method.


## Network Model

We use the Julia Geometry2D package to generate the network topology. This Julia package generates random ellipses and points, which are used to represent the Autonomous Systems (ASes) and PoPs (Points of Presence). The links between ASes are established when both ASes are present in the same PoP. If the points do not fall into the intersection of two ellipses, we will ignore them. The links also describe the AS business relationships, and will discuss it in Autonomous System(AS) Relationship Policy Section.

Based on the area of random ellipses, we define the type of Autonomous Systems:  
* Tier-1: ASes that only provide transit and never buy it. 
 * Tier-X: ASes that both provide and buy transit. Providers can be other Tier-1 or other Tier-X.
* Stubs: ASes that appear only at the beginning of the AS path. They only buy transit (from both Tier-1 and Tier-X) and never provide it. 

We use the metrics to represent the generated data for further study. The network topology is captured through the Connection Matrix C. Each matrix element indicates whether two ASes have a connection at a specific PoPs.

The business relationships are captured through the relationship matrix R. Our model does not pose any limitation on the number or type of policies that can be captured. On the contrary, our design was guided by the idea to allow a diverse set of policies for the user to define. 

For our initial experiments, we maintain a set of policies often used in the literature, and  we codify each relationship type through an integer number. 

* 1 : provider-to-customer (p2c);
* 2 : customer-to-provider (c2p);
* 3 : peer-2-peer (p2p)

 A more diverse set of policies can be modeled by assigning additional integers to corresponding relationship types. A relationship type could also be compound, i.e., being the result of merging together with other policies.

## Latin Multiplication Method
Latin-Multiplication is an algebraic method useful in enumerating paths. Let X* be the set of all paths, which includes the empty path $\emptyset$. Latin-Multiplication $\otimes$ between two paths $u_{\alpha i}$ and $u_{\beta j}$ means path concatenation if the last node of $u_{\alpha i}$ is the same as the first node of $u_{\beta j}$. In case this condition does not hold, the Latin-Multiplication between the two paths produces the empty path.

More formally,

if
u $\otimes$ $\emptyset$ = $\emptyset$ $\otimes$ u $\qquad$ $\forall$ x $\in$ S \par
$u_{\alpha i}$ = ($i_{1}$,$i_{2}$,...$i_{k}$) 
$u_{\beta j}$ = ($j_{1}$,$j_{2}$,...$j_{l}$) 

then 
$u_{\alpha i}$ $\otimes$  $u_{\beta j}$ =  ($i_{1}$,$i_{2}$,...$i_{k}$, $j_{2}$,...$j_{l}$) if $i_{k}$ = $j_{1}$
else
$u_{\alpha i}$ $\otimes$  $u_{\beta j}$ = $\emptyset$ if $i_{k}$ $\neq$ $j_{1}$



Assume that matrix $u_{\alpha}$ is two dimensional and contains elements that are paths. For instance, element $u_{\alpha i}$ would be a path starting from node $i_{1}$ and ending at node  $i_{k}$ located at position $(1, k)$ of the matrix. If matrix $u_{\beta}$ also contains paths of the same nodes, then we can define multiplication between two path matrices as:

if $u_{\alpha}$ = ($u_{\alpha i}$) $\qquad$ with $u_{\alpha i}$ $\in$ X*, \par
$\hphantom{i,}$ $u_{\beta}$ = ($u_{\beta j}$) $\qquad$ with $u_{\beta j}$ $\in$ X*, \par 
then $u_{\alpha}$ $\otimes$ $u_{\beta}$ = {($u_{\alpha i}$ $\otimes$ $u_{\beta j}$)}.


## Autonomous System(AS) Relationship Policy

The Autonomous System(AS) relationship policies often imply rules on path validity and preference. In our example set of policies, we have implemented the valley-free set of rules to distinguish between valid and invalid paths. A path that does not follow the valley-free rules is invalid.

The valley-free rules define routing path patterns. Assuming n and m are positive integers, a routing path is valley-free, if and only if it consists of links that follow one of these two business relationship patterns:

 * n* c2p + m* p2c  
 * n* c2p + p2p + m* p2c 
where n and m > 0. 

In other words, there should not be adjacent p2p links within a valid routing path, and a c2p link should not follow a p2c link. 

Our model allows one to define arbitrary policy rules, the valley free set being just an example. We also mark a path as invalid if it contains the same node twice, calling it a loop. A loop describes the case where a packet keeps getting routed in an endless circle through the same nodes rather than reaching its intended destination.

In our initial experiments, a path is valid if it obeys both the valley-free rules and loop-free rule.

## Router Level Network Generation

In the previous section, we discuss the Network model. The original network model used the Julia Geometry2D to generate the AS level network topology. In this section, we will discuss how to generate router-level network topology and how to simulate router-level routing paths.

For the router generation, we use the Julia Geometry2D package to generate random points within the ellipses(ASes), which represent the routers. Based on the type of ASes, we generate the different number of routers for each ASes:
* Tier-1 AS: 5 routers
* Tier-X AS: 3 routers
* Stubs AS: 1 router

And for each router, we random generate local preference value between 1 to 6. 

## Routing Path Solver

We have implemented three versions of the routing path solver based on the A* algorithm and path matrix multiplication method in the high-performance programming language Julia:
* Serial Implementation with Julia Build in Array
*  Parallel Implementation with Julia Build in Array
* Parallel Implementation with Julia Shared-Array


The Julia built-in array is an ordered collection of elements. Julia Shared Arrays use system shared memory to map the same array across many processes. Implementing the Shared Array data structure takes advantage of the shared memory parallel programming model across all processes. 

In Julia, only "isbits" elements are supported in a Shared-Array. Each element of the Shared-Array must be of Bit type, which is a Julia "plain data" type, meaning it is immutable and contains no references to other values.

To represent the path in our path solver, we use arrays of the array with Julia Build in Array. For instance, path P = [[1,2,3],[1,4,3]]. But in the Julia Shared-Array, arrays of the array is not allowed since arrays are not the Bit type. 

The common elements of all three implementations are depicted in the following Figure.
![Flowchart of the Path Solver](https://github.com/gn8bamboo/ALL-PAIRS-ROUTING-PATH-ENUMERATION-USING-LATIN-MULTIPLICATION-AND-JULIA/blob/main/Flowchart.png)

The parallel A* implementation parallelizes the matrix multiplication dividing column of Link matrix L among different threads that all share Path matrix $P_{i}$ and produce other rows of the matrix $P_{i+1}$. The parallel process is described in the following Figure. 
![Flowchart of the Paralle Path Solver](https://github.com/gn8bamboo/ALL-PAIRS-ROUTING-PATH-ENUMERATION-USING-LATIN-MULTIPLICATION-AND-JULIA/blob/main/parellel.png)

## Path Prefix Attack
In our original routing path solver, each node of the network announces a unique IP prefix. In the path prefix attack model, we select a node to act maliciously and pretend to be the origin of a prefix that belongs to a different node. The path prefix attack process is depicted in Figure.
![Process of Path Prefix Attack](https://github.com/gn8bamboo/ALL-PAIRS-ROUTING-PATH-ENUMERATION-USING-LATIN-MULTIPLICATION-AND-JULIA/blob/main/Flowchart-Origin.png)

The only difference with the general path solver process, Link Matrix $L$ does not equal Path Matrix $P_{0}$. We build a new Path Matrix $P_{0}$ in the path prefix attack process by inserting fake paths.

We analyze the network depicted to find the most vulnerable nodes for a path origin attack. For each network node, we run experiments in which one of the other network nodes performed a path origin attack impersonating it. We also counted every node result and calculated the total attack percentage of the network. 

#lang dssl2

# HW4: Graph
#
# ** You must work on your own for this assignment. **
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
import cons


###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WU_GRAPH:

    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then exactly one of WEdge(1, 3, 10) or WEdge(3, 1, 10)
    # will be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?
# cons(2, weight)
struct data:
    let value
    let weight
class WuGraph (WU_GRAPH):
    let size
    let g
    def __init__(self, size: nat?):
        #size will be the amount of vertices
        self.size = size
        self.g = [None; size]
        
        
### ^ YOUR CODE HERE

    def len(self):
        return self.size
### ^ YOUR CODE HERE

    def set_edge(self, u, v, weight):
        #use cons and assing weight = w in the struct
        #if u exists
        #((2, w), cons(3, 2, cons(4. w, cons)
        def helper(u, v, weight):
            let current = self.g[u]
            while current != None:
                if current.data.value == v:
                    current.data.weight = weight
                    return None
                current = current.next
            self.g[u] = cons(data(v, weight), self.g[u])
            
        def delhelper(u, v, weight):
            if self.g[u] != None and self.g[u].data.value == v:
                self.g[u] = self.g[u].next
            else:            
                let current = self.g[u]
                while current != None:
                    if current.next != None:
                        if current.next.data.value == v:
                            current.next = current.next.next
                            return None
                    current = current.next
                    
                
                      #logic from assignment 3 using current next and nextnext
                      #and then we'll wanna call helper in the case that weight isnt none and
        if weight != None:              # delhelper in the case that weight Is none
            helper(u, v, weight)
            helper(v, u, weight)
        if weight == None:
            delhelper(u, v, weight)
            delhelper(v, u, weight)
### ^ YOUR CODE HERE

    def get_edge(self, u, v):
        #return a the weight from the edge 
        let current = self.g[u]
        while current != None:
            if current.data.value == v:
                return current.data.weight
            current = current.next
        return None
### ^ YOUR CODE HERE

    def get_adjacent(self, v):
        let VL = None
        let current = self.g[v]
        while current != None:
            VL = cons(current.data.value, VL)
            current = current.next
        return VL
### ^ YOUR CODE HERE

    def get_all_edges(self):
        #for i in range(length(g))
        let AE = None
        for i in range(len(self.g)):
            let current = self.g[i]
            while current != None:
                if i <= current.data.value:
                    AE = cons(WEdge(i, current.data.value, current.data.weight), AE)
                current = current.next
        return AE
### ^ YOUR CODE HERE

###
### List helpers
###

# For testing functions that return lists, we provide a function for
# constructing a list from a vector, and functions for sorting (since
# the orders of returned lists are not determined).

# list : VecOf[X] -> ListOf[X]
# Makes a linked list from a vector.
def list(v: vec?) -> Cons.list?:
    return Cons.from_vec(v)

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
# ASSUMPTION: There's no need to compare weights because
# the same edge can’t appear with different weights.
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    return Cons.sort[WEdge?](edge_lt?, lst)

###
### BUILDING GRAPHS
###

def example_graph() -> WuGraph?:
    let result = WuGraph(6) # 6-vertex graph from the assignment
    result.set_edge(0, 1, 12)
    result.set_edge(1, 3, 56)
    result.set_edge(1, 2, 31)
    result.set_edge(3, 5, 1)
    result.set_edge(2, 4, -2)
    result.set_edge(2, 5, 7)
    result.set_edge(3, 4, 9)
    return result
    
### ^ YOUR CODE HERE

struct CityMap:
    let graph: WuGraph?
    let dict: VecC[str?]


def my_neck_of_the_woods():
    let dict= ['Montreal', 'Laval', 'Repentigny', 'Terrebonne', 'Saint-Jean-Port-Joli',
                    'Saint-Charles-sur-Richelieu']
                    
    let graph = WuGraph(6)
    graph.set_edge(0, 1, 97)
    graph.set_edge(0, 2, 26)
    graph.set_edge(1, 2, 50)
    graph.set_edge(1, 3, 69)
    graph.set_edge(2, 4, 32)
    graph.set_edge(4, 5, 84)
    graph.set_edge(3, 5, 73)
    return CityMap(graph, dict)
    ### ^ YOUR CODE HERE

###
### DFS
###

# dfs : WU_GRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WU_GRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    let finished = [False; graph.len()]
    def Travel(v):
        if not finished[v]:
            finished[v] = True
            f(v)
            let adj = graph.get_adjacent(v)
            while adj != None:
                Travel(adj.data)
                adj = adj.next
    Travel(start)
### ^ YOUR CODE HERE

# dfs_to_list : WU_GRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the test below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WU_GRAPH!, start: Vertex?) -> VertexList?:
    let builder = Cons.Builder()
    dfs(graph, start, builder.snoc)
    return builder.take()

###
### TESTING
###

## You should test your code thoroughly. Here is one test to get you started:
test "graph making":
    let graph = WuGraph(7)
    graph.set_edge(0, 1, 1)
    graph.set_edge(0, 2, 2)
    graph.set_edge(1, 3, 3)
    graph.set_edge(1, 4, 4)
    graph.set_edge(2, 5, 5)
    assert sort_vertices(graph.get_adjacent(0)) == list([1, 2])
    assert sort_vertices(graph.get_adjacent(1)) ==list([0, 3, 4])
    assert graph.get_all_edges() == list([WEdge(2, 5, 5), WEdge(1, 3, 3), WEdge(1, 4, 4), WEdge(0, 1, 1), WEdge(0, 2, 2)])
    assert graph.get_edge(3, 2) == None
    assert graph.get_edge(0, 1) == 1
    assert graph.get_edge(0, 0) == None
    assert graph.get_edge(1, 0) == 1
    assert graph.len() == 7
    graph.set_edge(1, 3, 99)
    assert graph.get_edge(1, 3) == 99
    assert graph.get_edge(6, 3) == None
    graph.set_edge(0, 1, None)
    graph.set_edge(0, 2, None)
    graph.set_edge(1, 3, None)
    graph.set_edge(1, 4, None)
    graph.set_edge(2, 5, None)
    assert graph.get_edge(0, 1) == None
    assert graph.get_edge(0, 2) == None
    assert graph.get_edge(1, 3) == None
    assert graph.get_edge(1, 4) == None
    assert graph.get_edge(2, 5) == None
    assert graph.get_adjacent(1) == None
    let graph0 = WuGraph(0)
    assert graph0.len() == 0
    
    let djgraph = WuGraph(6)
    djgraph.set_edge(0, 1, 1)
    djgraph.set_edge(0, 2, 2)
    djgraph.set_edge(3, 4, 3)
    djgraph.set_edge(3, 5, 4)
    assert djgraph.len() == 6
    assert sort_vertices(djgraph.get_adjacent(0)) == list([1, 2])
    assert sort_vertices(djgraph.get_adjacent(3)) == list([4, 5])
    assert sort_edges(djgraph.get_all_edges()) == sort_edges(list([WEdge(0, 1, 1), WEdge(0, 2, 2), WEdge(3, 4, 3), WEdge(3, 5, 4)]))
    djgraph.set_edge(0, 1, None)
    djgraph.set_edge(0, 2, None)
    djgraph.set_edge(3, 4, None)
    djgraph.set_edge(3, 5, None)
    assert djgraph.get_edge(0, 1) == None
    assert djgraph.get_edge(0, 2) == None
    assert djgraph.get_edge(3, 4) == None
    assert djgraph.get_edge(3, 5) == None
    assert djgraph.len() == 6
    
    let graph3 = WuGraph(6)
    graph3.set_edge(0, 1, 1)
    graph3.set_edge(0, 0, 50)
    graph3.set_edge(0, 2, 2)
    graph3.set_edge(1, 3, 3)
    graph3.set_edge(1, 4, 4)
    graph3.set_edge(2, 5, 5)
    assert sort_edges(graph3.get_all_edges()) == sort_edges(list([WEdge(0, 1, 1), WEdge(0, 0, 50), WEdge(0, 2, 2), WEdge(1, 3, 3), WEdge(1, 4, 4), WEdge(2, 5, 5)])) 
    assert graph3.get_edge(3, 2) == None
    assert graph3.get_edge(0, 1) == 1
    assert graph3.get_edge(0, 0) == 50
    assert graph3.get_edge(1, 0) == 1
    graph3.set_edge(0, 0, 54)
    assert graph3.get_edge(0, 0) == 54
    graph3.set_edge(0, 0, None)
    assert graph3.get_edge(0, 0) == None
    
test 'dfs_to_list(example_graph())':
    assert sort_vertices(dfs_to_list(example_graph(), 0)) \
        == list([0, 1, 2, 3, 4, 5])
    let graph = WuGraph(6)
    graph.set_edge(0, 1, 97)
    graph.set_edge(0, 2, 26)
    graph.set_edge(1, 2, 50)
    graph.set_edge(1, 3, 69)
    graph.set_edge(2, 4, 32)
    graph.set_edge(4, 5, 84)
    graph.set_edge(3, 5, 73)
    assert sort_vertices(dfs_to_list(graph, 0)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph, 1)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph, 2)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph, 3)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph, 4)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph, 5)) \
        == list([0, 1, 2, 3, 4, 5])
    assert dfs_to_list(example_graph(), 0) \
        == list([0, 1, 3, 5, 2, 4])
    let graph1 = WuGraph(6)
    graph1.set_edge(0, 1, 1)
    graph1.set_edge(0, 2, 2)
    graph1.set_edge(1, 3, 3)
    graph1.set_edge(1, 4, 4)
    graph1.set_edge(2, 5, 5)
    assert dfs_to_list(graph1, 0) \
        == list([0, 1, 3, 4, 2, 5])
    assert dfs_to_list(graph1, 1) \
        == list([1, 0, 2, 5, 3, 4])
    assert dfs_to_list(graph1, 2) \
        == list([2, 0, 1, 3, 4, 5])
        #my dfs search's behavior is to go upwards if possible and then go dfs towards the right
        #unless to the right is a node we have already been at then itll head left and then go dfs towards the right
        #and finally then itll go past the node we had already been at that sent it left in order to check beneath it
        #at least thats the impression i recieved while working on this tree i made
    assert dfs_to_list(graph1, 3) \
        == list([3, 1, 0, 2, 5, 4])
    assert dfs_to_list(graph1, 4) \
        == list([4, 1, 0, 2, 5, 3])
    assert dfs_to_list(graph1, 5) \
        == list([5, 2, 0, 1, 3, 4])
    assert sort_vertices(dfs_to_list(graph1, 0)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph1, 1)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph1, 2)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph1, 3)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph1, 4)) \
        == list([0, 1, 2, 3, 4, 5])
    assert sort_vertices(dfs_to_list(graph1, 5)) \
        == list([0, 1, 2, 3, 4, 5])
    let graph3 = WuGraph(6)
    graph3.set_edge(0, 1, 1)
    graph3.set_edge(0, 0, 50)
    graph3.set_edge(1, 1, 51)
    graph3.set_edge(0, 2, 2)
    graph3.set_edge(1, 3, 3)
    graph3.set_edge(1, 4, 4)
    graph3.set_edge(2, 5, 5)
    assert sort_vertices(dfs_to_list(graph3, 0)) \
        == list([0, 1, 2, 3, 4, 5])
    assert dfs_to_list(graph3, 0) \
        == list([0, 1, 3, 4, 2, 5])
    assert dfs_to_list(graph3, 1) \
        == list([1, 0, 2, 5, 3, 4])
    assert dfs_to_list(graph3, 2) \
        == list([2, 0, 1, 3, 4, 5])
    let graph01 = WuGraph(1)
    assert dfs_to_list(graph01, 0) \
        == list([0])
        
    let djgraph = WuGraph(6)
    djgraph.set_edge(0, 1, 1)
    djgraph.set_edge(0, 2, 2)
    djgraph.set_edge(3, 4, 3)
    djgraph.set_edge(3, 5, 4)
    assert sort_vertices(dfs_to_list(djgraph, 3)) \
        == list([3, 4, 5])
    assert sort_vertices(dfs_to_list(djgraph, 1)) \
        == list([0, 1, 2])

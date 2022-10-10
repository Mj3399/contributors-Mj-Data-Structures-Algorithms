#lang dssl2

# Final project: Trip Planner
#
# ** You must work on your own for this assignment. **

# Your program will most likely need a number of data structures, many of
# which you've implemented in previous homeworks.
# We have provided you with compiled versions of homework 3, 4, and 5 solutions.
# You can import them as described in the handout.
# Be sure to extract `project-lib.zip` is the same directory as this file.
# You may also import libraries from the DSSL2 standard library (e.g., cons,
# array, etc.).
# Any other code (e.g., from lectures) you wish to use must be copied to this
# file.
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
import cons
import 'project-lib/dictionaries.rkt'
import 'project-lib/binheap.rkt'
import 'project-lib/dictionaries.rkt'
import 'project-lib/graph.rkt'
import 'project-lib/stack-queue.rkt'

### Basic Vocabulary Types ###

#  - Latitudes and longitudes are numbers:
let Lat?  = num?
let Lon?  = num?
#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC

# List of unspecified element type (constant time):
let List? = Cons.list?


### Input Types ###

#  - a SegmentVector  is VecC[SegmentRecord]
#  - a PointVector    is VecC[PointRecord]
# where
#  - a SegmentRecord  is [Lat?, Lon?, Lat?, Lon?]
#  - a PointRecord    is [Lat?, Lon?, Cat?, Name?]


### Output Types ###

#  - a NearbyList     is ListC[PointRecord]; i.e., one of:
#                       - None
#                       - cons(PointRecord, NearbyList)
#  - a PositionList   is ListC[Position]; i.e., one of:
#                       - None
#                       - cons(Position, PositionList)
# where
#  - a PointRecord    is [Lat?, Lon?, Cat?, Name?]  (as above)
#  - a Position       is [Lat?, Lon?]


# Interface for trip routing and searching:
interface TRIP_PLANNER:
    # Finds the shortest route, if any, from the given source position
    # (latitude and longitude) to the point-of-interest with the given
    # name. (Returns the empty list (`None`) if no path can be found.)
    def find_route(
            self,
            src_lat:  Lat?,     # starting latitude
            src_lon:  Lon?,     # starting longitude
            dst_name: Name?     # name of goal
        )   ->        List?     # path to goal (PositionList)

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position. (Ties for nearest are broken
    # arbitrarily.)
    def find_nearby(
            self,
            src_lat:  Lat?,     # starting latitude
            src_lon:  Lon?,     # starting longitude
            dst_cat:  Cat?,     # point-of-interest category
            n:        nat?      # maximum number of results
        )   ->        List?     # list of nearby POIs (NearbyList)


class TripPlanner (TRIP_PLANNER):
    let PG #graph vertice graph
    let CD #category to vertice dictionary
    let ND #name to vertice dictionary 
    let PD #position to vertice dictionary
    let ID #vertice to position dictionary
    let VPD #vertice to POI dictionary
    let RV #road segment vector 1st in tripplanner
    let POIV #poi vector 2nd in tripplanner
    def __init__(self, RV, POIV):
        self.RV = RV
        self.POIV = POIV
        
        
        
        
        def makeG(RV, POIV):
            self.PD = AssociationList()
            self.ID = AssociationList()
            self.VPD = AssociationList()
            let vertices = 0
            for i in RV:
                let Pos1 = [i[0], i[1]]  #hear i reach into each road segment rip out the individual integers and put them into positions
                let Pos2 = [i[2], i[3]]
                if self.PD.mem?(Pos1) == False:
                    self.ID[vertices] = Pos1
                    self.PD[Pos1] = vertices
                    vertices = vertices + 1
                    self.VPD[self.PD[Pos1]] = None
                #in this area i am storing points into the PD dictionary, i.e. if u look up a point in PD you get the vertex you are on
                if self.PD.mem?(Pos2) == False:
                    self.ID[vertices] = Pos2
                    self.PD[Pos2] = vertices
                    vertices = vertices + 1
                    self.VPD[self.PD[Pos2]] = None
                    
            self.ND = AssociationList()
            self.CD = AssociationList()
                        
            let smthing = None
            for i in POIV:
                let category = i[2]
                let Name = i[3]
                let Pos1 = [i[0], i[1]]
                
                #case where its an island
                if self.PD.mem?(Pos1) == False:
                    self.ID[vertices] = Pos1
                    self.PD[Pos1] = vertices
                    vertices = vertices + 1
                    self.VPD[self.PD[Pos1]] = None
                self.CD[category] = self.PD[Pos1]
                self.ND[Name] = self.PD[Pos1]
                
                
                #need to make it possible to add multiple pois to one vertext using cons list
            for i in POIV:
                let Pos1 = [i[0], i[1]]
                self.VPD[self.PD[Pos1]] = cons([i[0], i[1], i[2], i[3]], self.VPD[self.PD[Pos1]])
                    
                 
                
            self.PG = WuGraph(vertices) #initializing a graph with vertice amount of vertexes
            for i in RV:
                let Pos1 = [i[0], i[1]]
                let Pos2 = [i[2], i[3]]  #here we are setting edges using the road segment vectors
                self.PG.set_edge(self.PD[Pos1], self.PD[Pos2], (((i[2]-i[0])*(i[2]-i[0])) + ((i[3]-i[1])*(i[3]-i[1]))).sqrt())
        makeG(self.RV, self.POIV) 
        
       #D for dijkstrah      
    def D(self, PG, start):
        let dist = [inf; PG.len()]
        let pred = [None; PG.len()]
        dist[start] = 0 
        let todo = BinHeap(PG.len()*PG.len(), λ x, y: dist[x] < dist[y])
        let done = [False; PG.len()]
        todo.insert(start)
        while todo.len() > 0:
            let v = todo.find_min()
            todo.remove_min()
            
            if done[v] == False:
                
                done[v] = True
                let current = PG.get_adjacent(v) 
                while current != None:
                    if dist[v] + PG.get_edge(v, current.data) < dist[current.data]:
                        dist[current.data] = dist[v] + PG.get_edge(v, current.data)
                        pred[current.data] = v
                        todo.insert(current.data)
                    current = current.next
        return [dist, pred]
            
        
            
    def find_route(
            self,
            src_lat:  Lat?,     # starting latitude
            src_lon:  Lon?,     # starting longitude
            dst_name: Name?     # name of goal
        ):  # ->        List?     # path to goal (PositionList)
        let pos = [src_lat, src_lon]
        let name = dst_name
        if self.PD.mem?(pos) == False:
            error('position doesnt exist')
        if self.ND.mem?(name) == False: 
            return None
        let SV = self.PD.get(pos)
        let DR = self.D(self.PG, SV)
        let GV = self.ND.get(name)
        let current = None 
        
        def predecessor(j):
             
             if j != SV:
                j = DR[1][j]
                current = cons(self.ID[j], current)
                predecessor(j)
                
                
        #if the distance to GV isnt inf go ahead otherwise stop
        if DR[0][GV] != inf:
            if GV == SV:
                current = cons(self.ID[GV], current)
                return current
            
            elif DR[1][GV] == SV:
                current = self.ID[GV]
                current = cons(pos, cons(current, None))
                return current
            else:
                current = cons(self.ID[GV], None)
                predecessor(GV)
                return current
      
        return current       
        
    def find_nearby(
            self,
            src_lat:  Lat?,     # starting latitude
            src_lon:  Lon?,     # starting longitude
            dst_cat:  Cat?,     # point-of-interest category
            n:        nat?      # maximum number of results
        ):  # ->        List?     # list of nearby POIs (NearbyList)
        let LIMIT = n
        let pos = [src_lat, src_lon]
        let cat = dst_cat
        if self.PD.mem?(pos) == False:
            error('position doesnt exist')
        if self.CD.mem?(cat) == False:
            return None
        let SV = self.PD.get(pos) #starting vertex
        let DR = self.D(self.PG, SV) #dijkstrah result
        let h = BinHeap[nat?](len(DR[0]), λ x, y: DR[0][x] < DR[0][y])
        for i in range(len(DR[0])):
            h.insert(i)
        let counter = 0
        let poilist = None
        while counter < LIMIT and h.len() != 0:
            if DR[0][h.find_min()] != inf:
                let current = self.VPD[h.find_min()]
                
                while current != None: 
                    if counter < LIMIT and current.data[2] == cat:
                        #println(current)
                        poilist = cons(current.data, poilist)
                        counter = counter + 1
                    current = current.next
            h.remove_min()                    
        return poilist
       
#### ^^^ YOUR CODE HERE
        

#let a = TripPlanner([[0,0, 0, 1], [0,0, 1, 0]], [[0,0, "bar", "The Empty Bottle"], [0,1, "food", "Pelmeni"]])
def my_first_example():
    return TripPlanner([[0,0, 0, 1], [0,0, 1, 0]],
                       [[0,0, "bar", "The Empty Bottle"],
                        [0,1, "food", "Pelmeni"]])


test 'My first find_route test':
   assert my_first_example().find_route(0, 0, "Pelmeni") == \
       cons([0,0], cons([0,1], None))
   assert my_first_example().find_route(0, 1, "The Empty Bottle") == \
       cons([0,1], cons([0,0], None))

test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == \
        cons([0,1, "food", "Pelmeni"], None)

def example_from_handout():
    pass
test 'MST is not SSSP (nearby)':
    let tp = TripPlanner(
      [[-1.1, -1.1, 0, 0],
       [0, 0, 3, 0],
       [3, 0, 3, 3],
       [3, 3, 3, 4],
       [0, 0, 3, 4]],
      [[0, 0, 'food', 'Sandwiches'],
       [3, 0, 'bank', 'Union'],
       [3, 3, 'barber', 'Judy'],
       [3, 4, 'barber', 'Tony']])
    let nearby = tp.find_nearby(-1.1, -1.1, 'barber', 1)
    #print(str(nearby))
    
    
    
test '0-step route':
    let tp = TripPlanner(
      [[0, 0, 1, 0]],
      [[0, 0, 'bank', 'Union']])
    let route = tp.find_route(0, 0, 'Union')
    assert Cons.to_vec(route) \
      == [[0, 0]]
    

test '2-step route':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [2.5, 0, 'barber', 'Tony']])
    let route = tp.find_route(0, 0, 'Tony')
    #print(str(route))
    
test '3-step route':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony']])
    let route = tp.find_route(0, 0, 'Tony')
    assert Cons.to_vec(route) \
      == [[0, 0], [1.5, 0], [2.5, 0], [3, 0]]
test 'from barber to bank':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony']])
    let route = tp.find_route(3, 0, 'Union')
    assert Cons.to_vec(route) \
      == [[3, 0], [2.5, 0], [1.5, 0]]
test 'BFS is not SSSP (route)':
    let tp = TripPlanner(
      [[0, 0, 0, 9],
       [0, 9, 9, 9],
       [0, 0, 1, 1],
       [1, 1, 2, 2],
       [2, 2, 3, 3],
       [3, 3, 4, 4],
       [4, 4, 5, 5],
       [5, 5, 6, 6],
       [6, 6, 7, 7],
       [7, 7, 8, 8],
       [8, 8, 9, 9]],
      [[7, 7, 'haberdasher', 'Archit'],
       [8, 8, 'haberdasher', 'Braden'],
       [9, 9, 'haberdasher', 'Cem']])
    let route = tp.find_route(0, 0, 'Cem')
    assert Cons.to_vec(route) \
      == [[0, 0], [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9]]
test 'MST is not SSSP (route)':
    let tp = TripPlanner(
      [[-1.1, -1.1, 0, 0],
       [0, 0, 3, 0],
       [3, 0, 3, 3],
       [3, 3, 3, 4],
       [0, 0, 3, 4]],
      [[0, 0, 'food', 'Sandwiches'],
       [3, 0, 'bank', 'Union'],
       [3, 3, 'barber', 'Judy'],
       [3, 4, 'barber', 'Tony']])
    let route = tp.find_route(-1.1, -1.1, 'Tony')
    assert Cons.to_vec(route) \
      == [[-1.1, -1.1], [0, 0], [3, 4]]
test 'Destination is the 2nd of 3 POIs at that location':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'bar', 'Pasta'],
       [5, 0, 'barber', 'Judy'],
       [5, 0, 'food', 'Jollibee']])
    let route = tp.find_route(0, 0, 'Judy')
    assert Cons.to_vec(route) \
      == [[0, 0], [1.5, 0], [2.5, 0], [3, 0], [4, 0], [5, 0]]
      
test 'Two equivalent routes':
    let tp = TripPlanner(
      [[-2, 0, 0, 2],
       [0, 2, 2, 0],
       [2, 0, 0, -2],
       [0, -2, -2, 0]],
      [[2, 0, 'cooper', 'Dennis']])
    let route = tp.find_route(-2, 0, 'Dennis')
    assert Cons.to_vec(route) \
      in [[[-2, 0], [0, 2], [2, 0]],
          [[-2, 0], [0, -2], [2, 0]]]
          
test 'BinHeap needs capacity > |V|':
    let tp = TripPlanner(
      [[0, 0, 0, 1],
       [0, 1, 3, 0],
       [0, 1, 4, 0],
       [0, 1, 5, 0],
       [0, 1, 6, 0],
       [0, 0, 1, 1],
       [1, 1, 3, 0],
       [1, 1, 4, 0],
       [1, 1, 5, 0],
       [1, 1, 6, 0],
       [0, 0, 2, 1],
       [2, 1, 3, 0],
       [2, 1, 4, 0],
       [2, 1, 5, 0],
       [2, 1, 6, 0]],
      [[0, 0, 'blacksmith', "Revere's Silver Shop"],
       [6, 0, 'church', 'Old North Church']])
    let route = tp.find_route(0, 0, 'Old North Church')
    assert Cons.to_vec(route) \
      == [[0, 0], [2, 1], [6, 0]]
test '1 bank nearby':
    let tp = TripPlanner(
      [[0, 0, 1, 0]],
      [[1, 0, 'bank', 'Union']])
    let nearby = tp.find_nearby(0, 0, 'bank', 1)
    assert Cons.to_vec(nearby) == [[1, 0, 'bank', 'Union']]
test '1 barber nearby':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony']])
    let nearby = tp.find_nearby(0, 0, 'barber', 1)
    assert Cons.to_vec(nearby) \
      == [[3, 0, 'barber', 'Tony']]
test 'find bank from barber':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony']])
    let nearby = tp.find_nearby(3, 0, 'bank', 1)
    assert Cons.to_vec(nearby) \
      == [[1.5, 0, 'bank', 'Union']]
test 'No POIs in requested category':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'barber', 'Judy']])
    let nearby = tp.find_nearby(0, 0, 'food', 1)
    assert Cons.to_vec(nearby) \
      == []
test 'Relevant POI isnt reachable':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let nearby = tp.find_nearby(0, 0, 'food', 1)
    assert Cons.to_vec(nearby) \
      == []
      
test 'MST is not SSSP (nearby)':
    let tp = TripPlanner(
      [[-1.1, -1.1, 0, 0],
       [0, 0, 3, 0],
       [3, 0, 3, 3],
       [3, 3, 3, 4],
       [0, 0, 3, 4]],
      [[0, 0, 'food', 'Sandwiches'],
       [3, 0, 'bank', 'Union'],
       [3, 3, 'barber', 'Judy'],
       [3, 4, 'barber', 'Tony']])
    let nearby = tp.find_nearby(-1.1, -1.1, 'barber', 1)
    assert Cons.to_vec(nearby) \
      == [[3, 4, 'barber', 'Tony']]
test '2 relevant POIs; 1 reachable':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let nearby = tp.find_nearby(0, 0, 'barber', 2)
    assert Cons.to_vec(nearby) \
      == [[3, 0, 'barber', 'Tony']]
test '2 relevant POIs; limit 3':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [4, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy']])
    let nearby = tp.find_nearby(0, 0, 'barber', 3)
    assert Cons.to_vec(nearby) \
      == [[5, 0, 'barber', 'Judy'], [3, 0, 'barber', 'Tony']]
test '2 relevant equidistant POIs; limit 1':
    let tp = TripPlanner(
      [[-1, -1, 0, 0],
       [0, 0, 3.5, 0],
       [0, 0, 0, 3.5],
       [3.5, 0, 0, 3.5]],
      [[-1, -1, 'food', 'Jollibee'],
       [0, 0, 'bank', 'Union'],
       [3.5, 0, 'barber', 'Tony'],
       [0, 3.5, 'barber', 'Judy']])
    let nearby = tp.find_nearby(-1, -1, 'barber', 1)
    assert Cons.to_vec(nearby) \
      in [[[3.5, 0, 'barber', 'Tony']],
          [[0, 3.5, 'barber', 'Judy']]]
test '3 relevant POIs; farther 2 at same location; limit 2':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'barber', 'Judy'],
       [5, 0, 'barber', 'Lily']])
    let nearby = tp.find_nearby(0, 0, 'barber', 2)
    assert Cons.to_vec(nearby) \
      in [[[5, 0, 'barber', 'Judy'], [3, 0, 'barber', 'Tony']],
          [[5, 0, 'barber', 'Lily'], [3, 0, 'barber', 'Tony']]]
test '3 relevant POIs; farther 2 equidistant; limit 2':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [0, 0, 'barber', 'Lily'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'barber', 'Judy']])
    let nearby = tp.find_nearby(2.5, 0, 'barber', 2)
    assert Cons.to_vec(nearby) \
      in [[[5, 0, 'barber', 'Judy'], [3, 0, 'barber', 'Tony']],
          [[0, 0, 'barber', 'Lily'], [3, 0, 'barber', 'Tony']]]
test 'POI is 2nd of 3 in that location':
    let tp = TripPlanner(
      [[0, 0, 1.5, 0],
       [1.5, 0, 2.5, 0],
       [2.5, 0, 3, 0],
       [4, 0, 5, 0],
       [3, 0, 4, 0]],
      [[1.5, 0, 'bank', 'Union'],
       [3, 0, 'barber', 'Tony'],
       [5, 0, 'food', 'Jollibee'],
       [5, 0, 'barber', 'Judy'],
       [5, 0, 'bar', 'Pasta']])
    let nearby = tp.find_nearby(0, 0, 'barber', 2)
    assert Cons.to_vec(nearby) \
      == [[5, 0, 'barber', 'Judy'], [3, 0, 'barber', 'Tony']]
#### ^^^ YOUR CODE HERE

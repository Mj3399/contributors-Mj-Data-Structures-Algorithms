#lang dssl2

# HW5: Binary Heaps
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
interface PRIORITY_QUEUE[X]:
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?
    # Returns the smallest element; error if empty.
    def find_min(self) -> X
    # Removes the smallest element; error if empty.
    def remove_min(self) -> NoneC
    # Inserts an element; error if full.
    def insert(self, element: X) -> NoneC

# Class implementing the PRIORITY_QUEUE ADT as a binary heap.
class BinHeap[X] (PRIORITY_QUEUE):
    let _data: VecC[OrC(X, NoneC)]
    let _size: nat?
    let _lt?:  FunC[X, X, bool?]

    # Constructs a new binary heap with the given capacity and
    # less-than function for type X.
    def __init__(self, capacity, lt?):
        self._data = [None; capacity]
        self._size = 0
        self._lt? = lt? 
#### ^^^ YOUR CODE HERE

    def len(self):
        return self._size
#### ^^^ YOUR CODE HERE

    def insert(self, new_element):
        self._data[self._size] = new_element
        self._size = self._size + 1
        def BU(i):
            '''print(str(i)+"|\n")
            print(str(self._data[i])+"\n")
            print(str(self._data[int((i-1) / 2)])+"\n")'''
            if self._lt?(self._data[i], self._data[int((i-1) / 2)]):
                let holder = self._data[int((i-1)/2)]
                self._data[int((i-1)/2)] = self._data[i]
                self._data[i] = holder
                BU(int((i-1)/2))
            return None
        BU(self._size - 1)
        
        
#### ^^^ YOUR CODE HERE

    def find_min(self):
        if self._size > 0:
            return self._data[0]
        error('empty binheap')
#### ^^^ YOUR CODE HERE

    def remove_min(self):   
        self._data[0] = self._data[self._size-1]
        self._data[self._size-1] = None
        self._size = self._size - 1
        def PD(i):
            if (2*i) + 1 < self._size:
                if (2*i) + 1 < self._size and (2*i) + 2 < self._size:
                    if self._lt?(self._data[(2*i) + 1], self._data[(2*i) + 2]):
                        if self._lt?(self._data[(2*i) + 1], self._data[i]):
                            let holder = self._data[i]
                            self._data[i] = self._data[(2*i) + 1]
                            self._data[(2*i) + 1] = holder
                            PD((2*i) + 1)
                    if self._lt?(self._data[(2*i) + 2], self._data[i]):
                        let holder = self._data[i]
                        self._data[i] = self._data[(2*i) + 2]
                        self._data[(2*i) + 2] = holder
                        PD((2*i) + 2)    
                if self._lt?(self._data[(2*i) + 1], self._data[i]):
                    let holder = self._data[i]
                    self._data[i] = self._data[(2*i) + 1]
                    self._data[(2*i) + 1] = holder
           
            return None
        PD(0)
        
                
            
        
        
        
#### ^^^ YOUR CODE HERE

# Woefully insufficient test.
test 'insert, insert, remove_min':
    # The `nat?` here means our elements are restricted to `nat?`s.
    let h = BinHeap[nat?](10, λ x, y: x < y)
    h.insert(3)
    h.insert(1)
    h.insert(0)
    assert h.find_min() == 0
    assert h.len() == 3
    h.remove_min()
    assert h.find_min() == 1
    h.remove_min() 
    assert h.find_min() == 3
    let g = BinHeap[nat?](5, λ x, y: x < y)
    g.insert(3)
    g.insert(6)
    g.insert(0)
    g.insert(2)
    g.insert(1)
    assert g.find_min() == 0
    g.remove_min()
    assert g.find_min() == 1
    g.remove_min()
    assert g.find_min() == 2
    g.remove_min()
    assert g.find_min() == 3
    g.remove_min()
    assert g.find_min() == 6
    let f = BinHeap[nat?](5, λ x, y: x > y)
    f.insert(3)
    f.insert(6)
    f.insert(0)
    f.insert(2)
    f.insert(1)
    assert f.find_min() == 6
    f.remove_min()
    assert f.find_min() == 3
    f.remove_min()
    assert f.find_min() == 2
    f.remove_min()
    assert f.find_min() == 1
    f.remove_min()
    assert f.find_min() == 0
    let f1 = BinHeap[nat?](5, λ x, y: 2*x > 2*y)
    f1.insert(3)
    f1.insert(6)
    f1.insert(0)
    f1.insert(2)
    f1.insert(1)
    assert f1.find_min() == 6
    f1.remove_min()
    assert f1.find_min() == 3
    f1.remove_min()
    assert f1.find_min() == 2
    f1.remove_min()
    assert f1.find_min() == 1
    f1.remove_min()
    assert f1.find_min() == 0
    let f2 = BinHeap[str?](5, λ x, y: len(x) > len(y))
    f2.insert("1")
    f2.insert("22")
    f2.insert("333")
    f2.insert("4444")
    f2.insert("")
    assert f2.find_min() == "4444"
    f2.remove_min()
    assert f2.find_min() == "333"
    f2.remove_min()
    assert f2.find_min() == "22"
    f2.remove_min()
    assert f2.find_min() == "1"
    f2.remove_min()
    assert f2.find_min() == ""
    let f4 = BinHeap[str?](5, λ x, y: len(x) < len(y))
    f4.insert("1")
    f4.insert("22")
    f4.insert("333")
    f4.insert("4444")
    f4.insert("")
    assert f4.find_min() == ""
    f4.remove_min()
    assert f4.find_min() == "1"
    f4.remove_min()
    assert f4.find_min() == "22"
    f4.remove_min()
    assert f4.find_min() == "333"
    f4.remove_min()
    assert f4.find_min() == "4444"
    let f3 = BinHeap[nat?](5, λ x, y: 2*x > 2*y)
    f3.insert(3)
    f3.insert(3)
    f3.insert(2)
    f3.insert(0)
    f3.insert(1)
    assert f3.find_min() == 3
    f3.remove_min()
    assert f3.find_min() == 3
    f3.remove_min()
    assert f3.find_min() == 2
    f3.remove_min()
    assert f3.find_min() == 1
    f3.remove_min()
    assert f3.find_min() == 0
    f3.remove_min()
    assert_error f3.find_min()
# Sorts a vector of Xs, given a less-than function for Xs.
#
# This function performs a heap sort by inserting all of the
# elements of v into a fresh heap, then removing them in
# order and placing them back in v.
def heap_sort[X](v: VecC[X], lt?: FunC[X, X, bool?]) -> NoneC:
    let H = BinHeap(len(v), lt?)
    let nv = [None; len(v)]
    for i in range(len(v)):
        H.insert(v[i])
    for i in range(len(v)):
        v[i] = H.find_min()
        H.remove_min()
    return None
#### ^^^ YOUR CODE HERE

test 'heap sort descending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x > y)
    assert v == [6, 3, 2, 1, 0]
test 'heap sort ascending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x < y)
    assert v == [0, 1, 2, 3, 6]
test 'heap same ascending':
    let v = [3, 3, 3, 3, 1]
    heap_sort(v, λ x, y: x < y)
    assert v == [1, 3, 3, 3, 3]
test 'heap same descending':
    let v = [3, 3, 3, 3, 1]
    heap_sort(v, λ x, y: x > y)
    assert v == [3, 3, 3, 3, 1]
test 'heap sort ascending x2':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: 2*x < 2*y)
    assert v == [0, 1, 2, 3, 6]
test 'heap string ascending':
    let v = ["1", "22", "333", "4444", ""]
    heap_sort(v, λ x, y: x < y)
    assert v == ["", "1", "22", "333", "4444"]
test 'heap string descending':
    let v = ["1", "22", "333", "4444", ""]
    heap_sort(v, λ x, y: x > y)
    assert v == ["4444", "333", "22", "1", ""]
# Sorting by birthday.

struct person:
    let name: str?
    let birth_month: nat?
    let birth_day: nat?
        
                                
def earliest_birthday() -> str?:
    let person1 = person("Sylvie", 8, 7)
    let person2 = person("Gabrielle", 8, 25)
    let person3 = person("Isabelle", 5, 6)
    let person4 = person("Julie", 8, 12)
    let person5 = person("Jean-Roch", 11, 12)
    let person6 = person("Olivier", 6, 10)
    let v =[person1, person2, person3, person4, person5, person6]
    def birthday(person):
        let bmn = person.birth_month * 100
        let BN = bmn + person.birth_day
        return BN
    heap_sort(v, λ x, y:  birthday(x) <  birthday(y))
    let result = v[0].name
    # person.birth_month, person.birth_day
    return result

test 'earliest birthday':
    earliest_birthday()
    assert earliest_birthday() == "Isabelle"
  
#### ^^^ YOUR CODE HERE
    
    
#?

def latest_birthday() -> str?:
    let person1 = person("Sylvie", 8, 7)
    let person2 = person("Gabrielle", 8, 25)
    let person3 = person("Isabelle", 5, 6)
    let person4 = person("Julie", 8, 12)
    let person5 = person("Jean-Roch", 11, 12)
    let person6 = person("Olivier", 6, 10)
    let v1 =[person1, person2, person3, person4, person5, person6]
    def birthday(person):
        let bmn = person.birth_month * 100
        let BN = bmn + person.birth_day
        return BN
    heap_sort(v1, λ x, y:  birthday(x) >  birthday(y))
    let result = v1[0].name
    return result
test 'latest birthday':
    latest_birthday()
    assert latest_birthday() == "Jean-Roch"

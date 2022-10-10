#lang dssl2

# HW3: Dictionaries
#
# ** You must work on your own for this assignment. **

import sbox_hash

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following three methods connect the `_ in _`, `_[_]` and
    # `_[_] = _` operators (as used in the example test below) to
    # your method implementations above. That is, when `h` is a
    # `DICT` then:
    #   - `k in h`    means  `h.mem?(k)`
    #   - `h[k]`      means  `h.get(k)`
    #   - `h[k] = v`  means  `h.put(k, v)`
    def __contains__(self, key: K)
    def __index_ref__(self, key: K)
    def __index_set__(self, key: K, value: V)
    # The following method allows dictionaries to be printed
    def __print__(self, print)

# Linked-list node struct (implementation detail):
struct _cons:
    let key
    let value
    let next: OrC(_cons?, NoneC)
class AssociationList[K, V] (DICT):

    let _head
    let length
    #   ^ ADDITIONAL FIELDS HERE

    def __init__(self):
        self._head = None
        self.length = 0
    #   ^ YOUR DEFINITION HERE

    def len(self) -> nat?:
        return self.length
    #   ^ YOUR DEFINITION HERE

    def mem?(self, key: K) -> bool?:
        let H = self._head
        for i in range(self.length):
            if H.key == key:
                return True
            H = H.next
        return False
                    
            
                
        
    #   ^ YOUR DEFINITION HERE

    def get(self, key: K) -> V:
        let H = self._head
        for i in range(self.length):
            if H.key == key:
                return H.value
            H = H.next
        error("key doesnt exist")
            
    #   ^ YOUR DEFINITION HERE

    def put(self, key: K, value: V) -> NoneC:
        let H = self._head
        for i in range(self.length):
            if H.key == key:
                H.value = value
                return None
            H = H.next
        self._head = _cons(key, value, self._head)
        self.length = self.length + 1
    #   ^ YOUR DEFINITION HERE

    def del(self, key: K) -> NoneC:
        if self._head != None and self._head.key == key:
            self._head = self._head.next
            self.length = self.length - 1
        else:            
            let H = self._head
            for i in range(self.length - 1):
                if H.next.key == key:
                    H.next = H.next.next
                    self.length = self.length - 1
                    return None
                H = H.next
    #   ^ YOUR DEFINITION HERE

    # See above.
    def __contains__(self, key): self.mem?(key)
    def __index_ref__(self, key): self.get(key)
    def __index_set__(self, key, value): self.put(key, value)
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert 'hello' not in a
    a['hello'] = 5
    assert 'h' not in a
    a['h'] = 21
    assert a.len() == 2
    a.del('h')
    assert a.len() == 1
    assert 'h' not in a
    assert 'hello' in a
    assert a['hello'] == 5
    a.del('hello') 
    assert 'hello' not in a
    assert 'sup' not in a
    a.del('sup')
    assert 'sup' not in a
    a.put('1', 1)
    a.put('2', 2)
    a.put('3', 3)
    a.put('4', 4)
    assert '1' in a
    assert '2' in a
    assert '3' in a
    assert '4' in a
    a.del('2')
    assert '2' not in a
    a.put('1', 29)
    assert '1' in a
    assert a.len() == 3
    assert a['1'] == 29
    a.del('4')
    assert a.len() == 2
    assert '4' not in a
    a.del('89')
    assert '89' not in a
    a.del('1')
    assert '1' not in a
    a.del('2') 
    assert '2' not in a
    assert a['3'] == 3
    a['3'] = 340
    assert a['3'] == 340
    a.del('3')
    assert '3' not in a 
    assert a.len() == 0
    assert_error a['2'] == 1

class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data
    let leng
    let nbuckets

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        # self._hash(K) =  
        self._data = [None; nbuckets]
        AssociationList()
        for i in range(len(self._data)):
            self._data[i] = AssociationList()
        self.leng = 0
        self.nbuckets = nbuckets
        self._size = self.leng
        
        pass
    #   ^ THE REST OF YOUR DEFINITION HERE

    def len(self) -> nat?:
        return self.leng
    #   ^ YOUR DEFINITION HERE

    def mem?(self, key: K) -> bool?:
        self._data[self._hash(key)%self.nbuckets].mem?(key)
    #   ^ YOUR DEFINITION HERE

    def get(self, key: K) -> V:
        self._data[self._hash(key)%self.nbuckets].get(key)
    #   ^ YOUR DEFINITION HERE

    def put(self, key: K, value: V) -> NoneC:
        if self.mem?(key) == False:
            self._data[self._hash(key)%self.nbuckets].put(key, value)
            self.leng = self.leng + 1
        self._data[self._hash(key)%self.nbuckets].put(key, value)
    #   ^ YOUR DEFINITION HERE

    def del(self, key: K) -> NoneC:
        if self.mem?(key) == True:
            self._data[self._hash(key)%self.nbuckets].del(key)
            self.leng = self.leng - 1
    #   ^ YOUR DEFINITION HERE

    # See above.
    def __contains__(self, key): self.mem?(key)
    def __index_ref__(self, key): self.get(key)
    def __index_set__(self, key, value): self.put(key, value)
    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)


# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, SboxHash64().hash)
    assert 'hello' not in h
    h['hello'] = 5
    assert 'h' not in h
    h['h'] = 21
    assert h.len() == 2
    h.del('h')
    assert h.len() == 1
    assert 'h' not in h
    assert 'hello' in h
    assert h['hello'] == 5
    h.del('hello') 
    assert 'hello' not in h
    assert 'sup' not in h
    h.del('sup')
    assert 'sup' not in h
    h.put('1', 1)
    h.put('2', 2)
    h.put('3', 3)
    h.put('4', 4)
    assert '1' in h
    assert '2' in h
    assert '3' in h
    assert '4' in h
    h.del('2')
    assert '2' not in h
    h.put('1', 29)
    assert '1' in h
    assert h.len() == 3
    assert h['1'] == 29
    h.del('4')
    assert h.len() == 2
    assert '4' not in h
    h.del('89')
    assert '89' not in h
    h.del('1')
    assert '1' not in h
    h.del('2') 
    assert '2' not in h
    assert h['3'] == 3
    h['3'] = 340
    assert h['3'] == 340
    h.del('3')
    assert '3' not in h 
    assert h.len() == 0
    assert_error h['2'] == 1
    let h1 = HashTable(1, SboxHash64().hash)
    h1.put('2', 2) 
    h1.put('3', 3)
    assert '2' in h1
    h1.del('2')
    assert '3' in h1
    let h2 = HashTable(3, first_char_hasher)
    h2.put('apple', 'app')
    h2.put('beer', 'bear')
    h2.put('bacon', 'bake')
    h2.put('candy', 'cane')
    assert 'apple' in h2
    assert 'beer' in h2
    assert 'bacon' in h2
    assert 'candy' in h2
    h2.del('bacon')
    assert 'bacon' not in h2
    assert 'beer' in h2
    assert h2['beer'] == 'bear'


def compose_menu(d: DICT!) -> DICT?:
    struct food:
        let food
        let type
            
    let food1 = food("Sushi", "Japanese")
    let food2 = food("Masala dosa", "Indian")
    let food3 = food("Apple pie", "American")
    let food4 = food("Pizza", "Italian")
    let food5 = food("Channa masala", "Indian")
    let food6 = food("Pupusas", "Salvadoran")
    d.put("Jesse", food1)
    d.put("Stevie", food2)
    d.put("Branden", food3)
    d.put("Steve", food4)
    d.put("Sara", food5)
    d.put("Iliana", food6)
    #println(d)
    return d
#   ^ YOUR, DEFINITION HERE

test "AssociationList menu":
    let a = AssociationList()
    a = compose_menu(a)
    assert a.get("Jesse").type == "Japanese"
    assert a.get("Stevie").type == "Indian"
    assert a.get("Branden").type == "American"
    assert a.get("Steve").type == "Italian"
    assert a.get("Sara").type == "Indian"
    assert a.get("Iliana").type == "Salvadoran"
    assert a.get("Jesse").food == "Sushi"
    assert a.get("Stevie").food == "Masala dosa"
    assert a.get("Branden").food == "Apple pie"
    assert a.get("Steve").food == "Pizza"
    assert a.get("Sara").food == "Channa masala"
    assert a.get("Iliana").food == "Pupusas"


test "HashTable menu":
    let h = HashTable(10, SboxHash64().hash)
    h = compose_menu(h)
    assert h.get("Jesse").type == "Japanese"
    assert h.get("Stevie").type == "Indian"
    assert h.get("Branden").type == "American"
    assert h.get("Steve").type == "Italian"
    assert h.get("Sara").type == "Indian"
    assert h.get("Iliana").type == "Salvadoran"
    assert h.get("Jesse").food == "Sushi"
    assert h.get("Stevie").food == "Masala dosa"
    assert h.get("Branden").food == "Apple pie"
    assert h.get("Steve").food == "Pizza"
    assert h.get("Sara").food == "Channa masala"
    assert h.get("Iliana").food == "Pupusas"

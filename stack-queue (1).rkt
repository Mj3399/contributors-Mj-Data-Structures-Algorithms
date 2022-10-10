#lang dssl2

# HW2: Stacks and Queues
#
# ** You must work on your own for this assignment. **

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

interface QUEUE[T]:
    def enqueue(self, element: T) -> NoneC
    def dequeue(self) -> T
    def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

    
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
###
### ListStack
###

class ListStack (STACK):
    let head
    let len

    # Any fields you may need can go here.

    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None
        self.len = 0
        
    #   ^ YOUR DEFINITION HERE

    # Other methods you may need can go here.
    #.push(self, element: T) -> NoneC
    
    def push(self, Element):
        if not Element == None:
            self.head = _cons(Element, self.head)
            self.len = self.len + 1
        
    
    
    #.pop(self) -> T
    
    def pop(self):
        if not self.head == None:
            let value = self.head.data
            self.head = self.head.next
            return value
        else: 
            error("Empty Stack")
        
    
    #.empty?(self) -> bool?
    def empty?(self):
        if self.head == None: 
            return True
        else:
            return False
        
test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert s.empty?() == False
    assert s.pop() == 2
    assert s.empty?() == True
    assert_error s.pop()
    s.push(None)
    assert s.empty?() == True

###
### ListQueue
###
class ListQueue (QUEUE):
    let head
    let len
    let tail
    # Any fields you may need can go here.

    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None
        self.len = 0
        self.tail = None
    #   ^ YOUR DEFINITION HERE

    # Other methods you may need can go here.
    
    #enqueue(self, element: T) -> NoneC
    
    def enqueue(self, T):  
        let N = _cons(T, None)
        if not T == None:
            if self.tail == None:
                self.head = N
                self.tail = N
                self.len = self.len + 1
            else:
                self.len = self.len + 1
                self.tail.next = N
                self.tail = N
        
    #dequeue(self) -> T
    def dequeue(self): 
        if not self.head == None:
            let value = self.head.data
            self.head = self.head.next
            if self.head == None:
                self.tail = None
            return value
        else: 
            error("Empty Stack")
        
        
    #empty?(self) -> bool?
    def empty?(self):
        if self.tail == None:
            return True
        else:
            return False
        
        
        
test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    assert q.empty?() == False
    assert q.dequeue() == 2
    assert q.empty?() == True
    assert_error q.dequeue()
    q.enqueue(None)
    assert q.empty?() == True
    


###
### Playlists
###

# Please include the RingBuffer class from Canvas here.
class RingBuffer[T] (QUEUE):
    let data
    let start
    let length

    def __init__(self, capacity):
        self.data = [None; capacity]
        self.start = 0
        self.length = 0

    def capacity(self):
        return self.data.len()

    def len(self):
        return self.length

    def empty?(self):
        return self.len() == 0

    def full?(self):
        return self.len() == self.capacity()

    def enqueue(self, element: T):
        if self.full?(): error('RingBuffer.enqueue: full')
        self.data[(self.start + self.length) % self.capacity()] = element
        self.length = self.length + 1

    def dequeue(self) -> T:
        if self.empty?(): error('RingBuffer.dequeue: empty')
        let result = self.data[self.start]
        self.data[self.start] = None
        self.length = self.length - 1
        self.start = (self.start + 1) % self.capacity()
        return result

def int_ring_buffer(capacity):
    return RingBuffer[int?](capacity)

test 'RingBuffer creation':
    let q = RingBuffer(8)
    assert q.capacity() == 8
    assert q.len() == 0
    assert q.empty?()
    assert not q.full?()

test 'RingBuffer empty dequeue':
    let q = RingBuffer(8)
    assert_error q.dequeue()

test 'RingBuffer enqueue and dequeue':
    let q = RingBuffer(8)
    q.enqueue(2)
    assert q.len() == 1
    q.enqueue(3)
    assert q.len() == 2
    assert q.dequeue() == 2
    assert q.len() == 1
    assert q.dequeue() == 3
    assert q.empty?()

test 'RingBuffer full enqueue':
    let q = RingBuffer(8)
    for i in range(8): q.enqueue(i)
    assert_error q.enqueue(9)

test 'RingBuffer wrap around':
    let q = RingBuffer(4)
    for i in range(4): q.enqueue(i)
    assert q.full?()
    assert q.dequeue() == 0
    assert q.dequeue() == 1
    q.enqueue(4)
    q.enqueue(5)
    assert q.full?()
    assert q.dequeue() == 2
    q.enqueue(6)
    assert q.dequeue() == 3
    assert q.dequeue() == 4
    assert q.dequeue() == 5
    assert q.dequeue() == 6

struct song:
    let title: str?
    let artist: str?
    let album: str?
    


# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    let song1 = song("Writhe", "Kyuss", "Blues for the Red Sun")
    let song2 = song("Into the Night", "Xiu Xiu", "Plays the Music of Twin Peaks")
    let song3 = song("Night Comes Out", "The Raveonettes", "Into the Night")
    let song4 = song("Percées de lumière", "Alcest", "Écailles de lune")
    let song5 = song("Moya", "Godspeed You! Black Emperor", "Slow Riot for New Zero Kanada")
    q.enqueue(song1)
    q.enqueue(song2)
    q.enqueue(song3)
    q.enqueue(song4)
    q.enqueue(song5)
    let first_song = q.dequeue()
    return first_song
#   ^ YOUR DEFINITION HERE

    '''Writhe — Kyuss — Blues for the Red Sun
• Into the Night — Xiu Xiu — Plays the Music of Twin Peaks
• Night Comes Out — The Raveonettes — Into the Night
• Percées de lumière — Alcest — Écailles de lune
• Moya — Godspeed You! Black Emperor — Slow Riot for New Zero Kanada'''
test "ListQueue playlist":
    let song1 = song("Writhe", "Kyuss", "Blues for the Red Sun")
    let song2 = song("Into the Night", "Xiu Xiu", "Plays the Music of Twin Peaks")
    let song3 = song("Night Comes Out", "The Raveonettes", "Into the Night")
    let song4 = song("Percées de lumière", "Alcest", "Écailles de lune")
    let song5 = song("Moya", "Godspeed You! Black Emperor", "Slow Riot for New Zero Kanada")
    let q = ListQueue()
    fill_playlist(q)
    assert q.dequeue() == song2
    assert q.dequeue() == song3
    assert q.dequeue() == song4
    assert q.dequeue() == song5
    assert_error q.dequeue()
test "RingBuffer playlist":
    let song1 = song("Writhe", "Kyuss", "Blues for the Red Sun")
    let song2 = song("Into the Night", "Xiu Xiu", "Plays the Music of Twin Peaks")
    let song3 = song("Night Comes Out", "The Raveonettes", "Into the Night")
    let song4 = song("Percées de lumière", "Alcest", "Écailles de lune")
    let song5 = song("Moya", "Godspeed You! Black Emperor", "Slow Riot for New Zero Kanada")
    let q = RingBuffer(5)
    fill_playlist(q)
    assert q.dequeue() == song2
    assert q.dequeue() == song3
    assert q.dequeue() == song4
    assert q.dequeue() == song5
    assert_error q.dequeue()
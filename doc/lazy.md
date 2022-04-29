# lazy.elv
1. [testing-status](#testing-status)
2. [make-iterator](#make-iterator)
3. [is-iterator](#is-iterator)
4. [init](#init)
5. [to-iter](#to-iter)
6. [cycle](#cycle)
7. [iterate](#iterate)
8. [nums](#nums)
9. [repeatedly](#repeatedly)
10. [repeat](#repeat)
11. [prepend](#prepend)
12. [take](#take)
13. [drop](#drop)
14. [rest](#rest)
15. [reductions](#reductions)
16. [each](#each)
17. [map](#map)
18. [map-indexed](#map-indexed)
19. [keep](#keep)
20. [filter](#filter)
21. [remove](#remove)
22. [interleave](#interleave)
23. [interpose](#interpose)
24. [unique](#unique)
25. [take-while](#take-while)
26. [drop-while](#drop-while)
27. [partition](#partition)
28. [partition-all](#partition-all)
29. [take-nth](#take-nth)
30. [drop-last](#drop-last)
31. [butlast](#butlast)
32. [keep-indexed](#keep-indexed)
33. [blast](#blast)
34. [first](#first)
35. [second](#second)
36. [nth](#nth)
37. [some](#some)
38. [first-pred](#first-pred)
39. [every](#every)
***
## testing-status
126 tests passed out of 126

100% of tests are passing

 
This module allows you to express infinite sequences.  Typically you start by providing input to a generator, then pipe them into any number of iterators, and finally pipe that to a consumer.
 
# Iterator structure
***
## make-iterator
 
Iterators have five zero-arity functions:
 
- init: performs any initialization steps.
 
- step: advances iteration to the next value.
 
- curr: outputs the next value.
 
- done: returns a boolean.  `true` if the iterator has been exhusted
 
`inf-iterator` & `nest-iterator` are convenience wrappers around `make-iterator`.
```elvish
make-iterator
▶ [&curr=<closure 0xc000f91800> &step=<closure 0xc000f918c0> &done=<closure 0xc000f91980> &init=<closure 0xc000f91740>]
```
```elvish
make-iterator &init={ } &curr={ } &step={ } &done={ }
▶ [&curr=<closure 0xc000f48000> &step=<closure 0xc000f480c0> &done=<closure 0xc000f48180> &init=<closure 0xc000a7bec0>]
```
***
## is-iterator
 
Simple predicate for iterators.  Runs `done` to be sure it returns a bool.
 
All of the iterators satisfy this predicate.
```elvish
range 10 | to-iter
▶ [&curr=<closure 0xc000ce7680> &step=<closure 0xc000ce7740> &done=<closure 0xc000ce7800> &init=<closure 0xc000ce75c0>]
```
```elvish
cycle a b c
▶ [&curr=<closure 0xc0006b98c0> &step=<closure 0xc0006b9980> &done=<closure 0xc0006b9a40> &init=<closure 0xc0006b9740>]
```
```elvish
iterate $base:inc~ (num 0)
▶ [&curr=<closure 0xc0006b8540> &step=<closure 0xc0006b8600> &done=<closure 0xc0006b86c0> &init=<closure 0xc0006b8480>]
```
```elvish
nums
▶ [&curr=<closure 0xc000f48a80> &step=<closure 0xc000f48b40> &done=<closure 0xc000f48e40> &init=<closure 0xc000f48840>]
```
```elvish
repeatedly { randint 100 }
▶ [&curr=<closure 0xc000b1e780> &step=<closure 0xc000f91c80> &done=<closure 0xc000b1e840> &init=<closure 0xc000f91b00>]
```
```elvish
repeat (randint 100)
▶ [&curr=<closure 0xc000f49800> &step=<closure 0xc000f91c80> &done=<closure 0xc000f498c0> &init=<closure 0xc000f91b00>]
```
```elvish
to-iter d e f | prepend [a b c]
▶ [&curr=<closure 0xc000709680> &step=<closure 0xc000709740> &done=<closure 0xc000709980> &init=<closure 0xc000709800>]
```
```elvish
range 10 | to-iter | take 5
▶ [&curr=<closure 0xc000d88240> &step=<closure 0xc000d88300> &done=<closure 0xc000d88540> &init=<closure 0xc000d88480>]
```
```elvish
cycle a b c | reductions $base:append~ []
▶ [&curr=<closure 0xc000d886c0> &step=<closure 0xc000d88780> &done=<closure 0xc000d88900> &init=<closure 0xc000d88840>]
```
```elvish
use str; nums &start=(num 65) | each $str:from-codepoints~
▶ [&curr=<closure 0xc000f04600> &step=<closure 0xc000f046c0> &done=<closure 0xc000f049c0> &init=<closure 0xc000f04900>]
```
```elvish
nums | keep {|n| if (base:is-even $n) { put $n }}
▶ [&curr=<closure 0xc000d3c9c0> &step=<closure 0xc000d3ca80> &done=<closure 0xc000d3cc00> &init=<closure 0xc000d3cb40>]
```
```elvish
nums | filter $base:is-even~
▶ [&curr=<closure 0xc000401080> &step=<closure 0xc000401140> &done=<closure 0xc0004012c0> &init=<closure 0xc000401200>]
```
```elvish
nums | remove $base:is-even~
▶ [&curr=<closure 0xc000401e00> &step=<closure 0xc000401ec0> &done=<closure 0xc000f90300> &init=<closure 0xc000f90000>]
```
```elvish
map $'+~' (to-iter (range 10)) (to-iter (range 10))
▶ [&curr=<closure 0xc000946180> &step=<closure 0xc000946300> &done=<closure 0xc000946480> &init=<closure 0xc000946000>]
```
```elvish
nums &start=10 &step=10 | map-indexed $'*~'
▶ [&curr=<closure 0xc0001758c0> &step=<closure 0xc000175980> &done=<closure 0xc000175a40> &init=<closure 0xc000175800>]
```
```elvish
range 10 | to-iter | drop 5
▶ [&curr=<closure 0xc0002d2840> &step=<closure 0xc0002d29c0> &done=<closure 0xc0002d3680> &init=<closure 0xc0002d35c0>]
```
```elvish
interleave (to-iter a b c) (to-iter 1 2 3)
▶ [&curr=<closure 0xc000bbe300> &step=<closure 0xc000bbe3c0> &done=<closure 0xc000bbe480> &init=<closure 0xc000bbe240>]
```
```elvish
interpose , (range 10 | to-iter )
▶ [&curr=<closure 0xc00037ba40> &step=<closure 0xc00037bb00> &done=<closure 0xc00037bd40> &init=<closure 0xc00037bbc0>]
```
```elvish
unique (to-iter a b b c c c a a a a d)
▶ [&curr=<closure 0xc000ba1200> &step=<closure 0xc000ba1380> &done=<closure 0xc000ba15c0> &init=<closure 0xc000ba1500>]
```
```elvish
unique (to-iter a b b c c c a a a a d) &count=$true
▶ [&curr=<closure 0xc000d01c80> &step=<closure 0xc000d01d40> &done=<closure 0xc000d01e00> &init=<closure 0xc000d01bc0>]
```
```elvish
nums | take-while {|n| < $n 5}
▶ [&curr=<closure 0xc00040dd40> &step=<closure 0xc00040de00> &done=<closure 0xc000f14300> &init=<closure 0xc000f140c0>]
```
```elvish
nums | drop-while {|n| < $n 5}
▶ [&curr=<closure 0xc00071c3c0> &step=<closure 0xc00071c480> &done=<closure 0xc00071c600> &init=<closure 0xc00071c540>]
```
```elvish
nums &stop=12 | partition 3
▶ [&curr=<closure 0xc000c2a240> &step=<closure 0xc000c2a3c0> &done=<closure 0xc000c2a540> &init=<closure 0xc000c2a0c0>]
```
```elvish
nums &stop=13 | partition-all 3
▶ [&curr=<closure 0xc000c2b440> &step=<closure 0xc000c2b500> &done=<closure 0xc000c2b5c0> &init=<closure 0xc000c2b380>]
```
```elvish
nums &stop=50 | take-nth 5
▶ [&curr=<closure 0xc000c2bbc0> &step=<closure 0xc000c2bc80> &done=<closure 0xc000c2be00> &init=<closure 0xc000c2bd40>]
```
```elvish
nums &stop=10 | drop-last 5
▶ [&curr=<closure 0xc0003043c0> &step=<closure 0xc000304600> &done=<closure 0xc0003052c0> &init=<closure 0xc000305080>]
```
```elvish
nums &stop=5 | butlast
▶ [&curr=<closure 0xc000766180> &step=<closure 0xc000766300> &done=<closure 0xc000766600> &init=<closure 0xc000766540>]
```
```elvish
to-iter a b c d e f g | keep-indexed {|i x| put [$i $x]} &pred=(fun:comp $base:first~ $base:is-odd~)
▶ [&curr=<closure 0xc000767980> &step=<closure 0xc000767bc0> &done=<closure 0xc000767d40> &init=<closure 0xc000767c80>]
```
***
## init
 
The init function means that iterators should "start over" from the beginning.
```elvish
   var iter = (range 10 | to-iter)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (cycle a b c)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (iterate $base:inc~ (num 0))
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (repeatedly { put x })
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (repeat (randint 100))
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (to-iter d e f | prepend [a b c])
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (range 10 | to-iter | take 5)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (cycle a b c | reductions $base:append~ [])
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   use str
   var iter = (nums &start=(num 65) | each $str:from-codepoints~)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums | keep {|n| if (base:is-even $n) { put $n }})
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums | filter $base:is-even~)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums | remove $base:is-even~)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (map $'+~' (to-iter (range 10)) (to-iter (range 10)))
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (nums &start=10 &step=10 | map-indexed $'*~')
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (range 10 | to-iter | drop 5)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (interleave (to-iter a b c) (to-iter 1 2 3))
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (interpose , (range 10 | to-iter ))
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (unique (to-iter a b b c c c a a a a d))
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (unique (to-iter a b b c c c a a a a d) &count=$true)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (nums | take-while {|n| < $n 5})
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums | drop-while {|n| < $n 5})
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums &stop=12 | partition 3)
   eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   
   var iter = (nums &stop=13 | partition-all 3)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (nums &stop=50 | take-nth 5)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (nums &stop=10 | drop-last 5)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var iter = (nums &stop=5 | butlast)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
   var pred = (fun:comp $base:first~ $base:is-odd~)
   var iter = (to-iter a b c d e f g | keep-indexed {|i x| put [$i $x]} &pred=$pred)
   eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   
```
```elvish
▶ $true
```
 
# Generators
***
## to-iter
 
Simplest generator.  Transforms an "array" to an iterator.
```elvish
to-iter (range 10) | blast
range 10 | to-iter | blast
```
```elvish
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## cycle
 
cycles an "array" infinitely.
```elvish
cycle a b c | take 10 | blast
put a b c | cycle | take 10 | blast
```
```elvish
▶ a
▶ b
▶ c
▶ a
▶ b
▶ c
▶ a
▶ b
▶ c
▶ a
```
***
## iterate
 
Returns an "array" of n, f(n), f(f(n)), etc.
```elvish
iterate $base:inc~ (num 0) | take 10 | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## nums
 
With no options, starts counting up from 0.
```elvish
nums | take 10 | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
 
You can tell it to start at a specific value.
```elvish
nums &start=10 | take 10 | blast
▶ 10
▶ 11
▶ 12
▶ 13
▶ 14
▶ 15
▶ 16
▶ 17
▶ 18
▶ 19
```
 
You can specify a step value.
```elvish
nums &step=2 | take 5 | blast
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
```
 
It can be negative.
```elvish
nums &step=-1 | take 10 | blast
▶ 0
▶ -1
▶ -2
▶ -3
▶ -4
▶ -5
▶ -6
▶ -7
▶ -8
▶ -9
```
 
Stop values can also be provided, although they offer little value over `range`.
```elvish
nums &stop=10 | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
 
`nums` returns nothing if the inputs make no sense.
```elvish
nums &step=-1 &stop=10 | blast
```
MATCHES EXPECTATIONS: `[nothing]`
***
## repeatedly
 
Takes a zero-arity function and calls it infinitely.
```elvish
repeatedly { randint 100 } | take 5 | blast
▶ 53
▶ 92
▶ 14
▶ 60
▶ 39
```
***
## repeat
 
Returns `x` infinitely
```elvish
repeat x | take 5 | blast
▶ x
▶ x
▶ x
▶ x
▶ x
```
 
# High-level iterators
***
## prepend
 
Prepends a list to an iterator
```elvish
to-iter d e f | prepend [a b c] | blast
▶ a
▶ b
▶ c
▶ d
▶ e
▶ f
```
***
## take
 
Like `builtin:take` but for iterators.
```elvish
cycle a b c | take 10 | blast
put a b c | cycle | take 10 | blast
```
```elvish
▶ a
▶ b
▶ c
▶ a
▶ b
▶ c
▶ a
▶ b
▶ c
▶ a
```
 
Exceeding the length of a nested iterator is handled gracefully.
```elvish
range 5 | to-iter | take 20 | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
```
***
## drop
 
Like `builtin:drop` but for iterators.
```elvish
range 10 | to-iter | drop 5 | blast
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
 
Dropping more than the nested iterator is handled gracefully.
```elvish
range 10 | to-iter | drop 20 | blast
```
MATCHES EXPECTATIONS: `[nothing]`
***
## rest
 
Drops the first element from the iterator.
```elvish
range 10 | to-iter | drop 5 | rest | blast
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## reductions
 
Like fun:reductions, but works with iterators.
```elvish
cycle a b c | reductions $base:append~ [] | take 5 | blast
▶ []
▶ [a]
▶ [a b]
▶ [a b c]
▶ [a b c a]
```
***
## each
 
Like `builtin:each, but works with iterators`.
```elvish
use str; nums &start=(num 65) | each $str:from-codepoints~ | take 3 | blast
▶ A
▶ B
▶ C
```
***
## map
 
Like `each`, but works with multiple iterators.
```elvish
map $'+~' (to-iter (range 10)) (to-iter (range 10)) | take 5 | blast
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
```
 
Can work like `each`, but you should avoid this because it is less performant.
```elvish
use str; nums &start=(num 65) | map $str:from-codepoints~ | take 3 | blast
▶ A
▶ B
▶ C
```
***
## map-indexed
 
Returns a sequence of `(f index element)`.
```elvish
nums &start=10 &step=10 | map-indexed $'*~' | take 5 | blast
▶ 0
▶ 20
▶ 60
▶ 120
▶ 200
```
***
## keep
 
Returns result of `(f x)` when it's non-nil & non-empty.
 
Notice how these two results are different depending on where you place the `take`.
```elvish
nums | take 10 | keep {|n| if (base:is-even $n) { put $n }} | blast
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
```
```elvish
nums | keep {|n| if (base:is-even $n) { put $n }} | take 10 | blast
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
▶ 10
▶ 12
▶ 14
▶ 16
▶ 18
```
***
## filter
 
Returns `x` when `(f x)` is non-empty & truthy.
```elvish
nums | filter $base:is-even~ | take 5 | blast
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
```
***
## remove
 
Returns `x` when `(complement (f x))` is non-empty & truthy.
```elvish
nums | remove $base:is-even~ | take 5 | blast
▶ 1
▶ 3
▶ 5
▶ 7
▶ 9
```
***
## interleave
 
Returns a sequence of the first item in each iterator, then the second, etc.
```elvish
interleave (to-iter a b c) (to-iter 1 2 3) | blast
▶ a
▶ 1
▶ b
▶ 2
▶ c
▶ 3
```
 
Understands when to stop short.
```elvish
interleave (to-iter a b) (to-iter 1 2 3) | blast
interleave (to-iter a b c) (to-iter 1 2) | blast
```
```elvish
▶ a
▶ 1
▶ b
▶ 2
```
***
## interpose
 
Returns the elements from the nested iterator, interposed with `sep`.
```elvish
interpose , (to-iter a b c) | blast
▶ a
▶ ,
▶ b
▶ ,
▶ c
```
 
Needs to elements from iter in order to interpose sep.
```elvish
interpose , (to-iter a) | blast
▶ a
```
***
## unique
 
Like `uniq` but for iterators.
```elvish
unique (to-iter a b b c c c a a a a) | blast
▶ a
▶ b
▶ c
▶ a
```
```elvish
unique (to-iter a b b c c c a a a a d) | blast
▶ a
▶ b
▶ c
▶ a
▶ d
```
```elvish
unique (to-iter a b b c c c a a a a) &count=$true | blast
▶ [a (num 1)]
▶ [b (num 2)]
▶ [c (num 3)]
▶ [a (num 4)]
```
```elvish
unique (to-iter a b b c c c a a a a d) &count=$true | blast
▶ [a (num 1)]
▶ [b (num 2)]
▶ [c (num 3)]
▶ [a (num 4)]
▶ [d (num 1)]
```
 
Corner-case test
```elvish
unique (to-iter a) | blast
▶ a
```
```elvish
unique (to-iter a) &count=$true | blast
▶ [a (num 1)]
```
***
## take-while
 
Returns elements so long as `(f x)` returns $true.
```elvish
nums | take-while {|n| < $n 5} | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
```
***
## drop-while
 
Drops elements until `(f x)` returns false.
```elvish
nums | drop-while {|n| < $n 5} | take 5 | blast
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## partition
 
partitions an iterator into lists of size n.
```elvish
nums &stop=12 | partition 3 | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
```
 
Drops items which don't complete the specified list size.
```elvish
nums &stop=14 | partition 3 | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
```
 
Specify `&step=n` to specify a "starting point" for each partition.
```elvish
nums &stop=12 | partition 3 &step=5 | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 5) (num 6) (num 7)]
```
 
`&step` can be < than the partition size.
```elvish
nums &stop=4 | partition 2 &step=1 | blast
▶ [(num 0) (num 1)]
▶ [(num 1) (num 2)]
▶ [(num 2) (num 3)]
```
 
When there are not enough items to fill the last partition, a pad can be supplied.
```elvish
nums &stop=14 | partition 3 &pad=[a] | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12) (num 13) a]
```
 
The size of the pad may exceed what is used.
```elvish
nums &stop=13 | partition 3 &pad=[a b] | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12) a b]
```
 
...or not.
```elvish
nums &stop=13 | partition 3 &pad=[] | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12)]
```
***
## partition-all
 
Convenience function for `partition` which supplies `&pad=[]`.
 
Use when you don't want everything in the resultset.
```elvish
nums &stop=13 | partition-all 3 | blast
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12)]
```
***
## take-nth
 
Returns the nth element from the given iterator.
```elvish
nums &stop=50 | take-nth 5 | blast
▶ 0
▶ 5
▶ 10
▶ 15
▶ 20
▶ 25
▶ 30
▶ 35
▶ 40
▶ 45
```
***
## drop-last
 
Drops the last `n` elements from an iterator.
```elvish
nums &stop=10 | drop-last 5 | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
```
***
## butlast
 
Drops the last element from an iterator
```elvish
nums &stop=5 | butlast | blast
▶ 0
▶ 1
▶ 2
▶ 3
```
***
## keep-indexed
 
Returns all non-empty & non-nil results of `(f index item)`.
```elvish
to-iter a b c d e f g | keep-indexed {|i x| if (base:is-odd $i) { put $x } else { put $nil }} | blast
▶ b
▶ d
▶ f
```
 
And supply your own predicate.
```elvish
to-iter a b c d e f g | keep-indexed {|i x| put [$i $x]} &pred=(fun:comp $base:first~ $base:is-odd~) | blast
▶ [(num 1) b]
▶ [(num 3) d]
▶ [(num 5) f]
```
 
# consumers
***
## blast
 
Simplest consumer.  "Blasts" the iterator output to the terminal.
```elvish
range 10 | to-iter | blast
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## first
 
Returns the first element from an iterator.
```elvish
nums | first
▶ 0
```
***
## second
 
Returns the second element from an iterator.
```elvish
nums | second
▶ 1
```
***
## nth
 
Returns the nth element from an iterator
```elvish
nums | nth 25
▶ 24
```
***
## some
 
Returns the first truthy value from `(f x)`.
```elvish
nums &stop=20 | some {|i| < $i 50}
▶ $true
```
```elvish
nums &stop=20 | some {|i| > $i 50}
▶ $false
```
```elvish
nums &stop=20 | some {|i| if (< $i 50) { put $i } }
▶ 0
```
 
Might return nothing, if nothing fits.
```elvish
nums &stop=20 | some {|i| if (> $i 50) { put $i } }
```
MATCHES EXPECTATIONS: `[nothing]`
***
## first-pred
 
Like filter but returns the first value.
```elvish
nums &stop=20 | first-pred {|i| < $i 50}
▶ 0
```
```elvish
nums | first-pred {|i| > $i 50}
▶ 51
```
```elvish
nums &stop=20 | first-pred {|i| > $i 50}
```
MATCHES EXPECTATIONS: `[nothing]`
***
## every
 
Returns `$true` if every element satisfies the predicate.  `$false` otherwise.
```elvish
nums &stop=20 | every {|i| < $i 50}
▶ $true
```
```elvish
nums | every {|i| < $i 50}
▶ $false
```

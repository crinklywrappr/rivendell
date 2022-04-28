# Fun.elv
1. [testing-status](#testing-status)
2. [listify](#listify)
3. [concat](#concat)
4. [first](#first)
5. [second](#second)
6. [end](#end)
7. [min-key/max-key](#min-key/max-key)
8. [group-by](#group-by)
9. [frequencies](#frequencies)
10. [map-invert](#map-invert)
11. [rand-sample](#rand-sample)
12. [sample](#sample)
13. [shuffle](#shuffle)
14. [union](#union)
15. [difference](#difference)
16. [disj](#disj)
17. [intersection](#intersection)
18. [subset](#subset)
19. [superset](#superset)
20. [overlaps](#overlaps)
21. [update](#update)
22. [vals](#vals)
23. [kvs](#kvs)
24. [merge](#merge)
25. [merge-with](#merge-with)
26. [select-keys](#select-keys)
27. [get-in](#get-in)
28. [assoc-in](#assoc-in)
29. [update-in](#update-in)
30. [rename-keys](#rename-keys)
31. [index](#index)
32. [destruct](#destruct)
33. [complement](#complement)
34. [partial](#partial)
35. [juxt](#juxt)
36. [constantly](#constantly)
37. [comp](#comp)
38. [box](#box)
39. [memoize](#memoize)
40. [repeatedly](#repeatedly)
41. [reduce](#reduce)
42. [reduce-kv](#reduce-kv)
43. [reductions](#reductions)
44. [filter](#filter)
45. [remove](#remove)
46. [into](#into)
47. [reverse](#reverse)
48. [distinct](#distinct)
49. [unique](#unique)
50. [replace](#replace)
51. [interleave](#interleave)
52. [interpose](#interpose)
53. [partition](#partition)
54. [partition-all](#partition-all)
55. [iterate](#iterate)
56. [take-nth](#take-nth)
57. [take-while](#take-while)
58. [drop-while](#drop-while)
59. [drop-last](#drop-last)
60. [butlast](#butlast)
61. [some](#some)
62. [first-pred](#first-pred)
63. [every](#every)
64. [not-every](#not-every)
65. [not-any](#not-any)
66. [keep](#keep)
67. [map](#map)
68. [mapcat](#mapcat)
69. [map-indexed](#map-indexed)
70. [zipmap](#zipmap)
71. [keep-indexed](#keep-indexed)
72. [pivot](#pivot)
***
## testing-status
216 tests passed out of 216

100% of tests are passing

 
# Misc. functions
***
## listify
 
Captures input and shoves it into a list.
```elvish
put 1 2 3 | listify
listify 1 2 3
```
```elvish
▶ [1 2 3]
```
***
## concat
 
A more generic version of `base:concat2`, which takes any number of lists
```elvish
concat [1 2 3] [4 5 6] [7 8 9]
put [1 2 3] [4 5 6] [7 8 9] | concat
```
```elvish
▶ [1 2 3 4 5 6 7 8 9]
```
***
## first
 
Returns the first element
```elvish
first a b c
put a b c | first
```
```elvish
▶ a
```
***
## second
 
Returns the second element
```elvish
second a b c
put a b c | second
```
```elvish
▶ b
```
***
## end
 
Returns the last element
```elvish
end a b c
put a b c | end
```
```elvish
▶ c
```
***
## min-key/max-key
 
Returns the x for which `(f x)`, a number, is least, or most.
 
If there are multiple such xs, the last one is returned.
```elvish
min-key $math:sin~ (range 20)
▶ 11
```
```elvish
max-key $math:sin~ (range 20)
▶ 14
```
 
# Statistics
***
## group-by
 
Returns a map of elements keyed by `(f x)`
```elvish
group-by $count~ a as asd aa asdf qwer
put a as asd aa asdf qwer | group-by $count~
```
```elvish
▶ [&(num 1)=[a] &(num 2)=[as aa] &(num 3)=[asd] &(num 4)=[asdf qwer]]
```
```elvish
group-by {|m| put $m[key]} [&key=a &val=1] [&key=b &val=1] [&key=a &val=3]
▶ [&a=[[&val=1 &key=a] [&val=3 &key=a]] &b=[[&val=1 &key=b]]]
```
***
## frequencies
 
Returns a map of the number of times a thing appears
```elvish
frequencies (each $all~ [abba acdc rush bush])
each $all~ [abba acdc rush bush] | frequencies
```
```elvish
▶ [&a=(num 3) &b=(num 3) &c=(num 2) &d=(num 1) &h=(num 2) &r=(num 1) &s=(num 2) &u=(num 2)]
```
***
## map-invert
 
Does what's on the tin
```elvish
map-invert [&a=1 &b=2 &c=3]
▶ [&1=a &2=b &3=c]
```
 
Normally lossy.
```elvish
map-invert [&a=1 &b=2 &c=1]
▶ [&1=c &2=b]
```
 
You can tell it not to be lossy, though.
```elvish
map-invert [&a=1 &b=2 &c=1] &lossy=$false
▶ [&1=[a c] &2=[b]]
```
***
## rand-sample
 
Returns items from `@arr` with random probability of 0.0-1.0
```elvish
rand-sample 0 (range 10)
```
MATCHES EXPECTATIONS: `[nothing]`
```elvish
rand-sample 0.5 (range 10)
▶ 0
▶ 1
▶ 3
▶ 5
▶ 7
▶ 8
```
```elvish
rand-sample 1 (range 10)
range 10 | rand-sample 1
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
## sample
 
Take n random samples from the input
```elvish
sample 5 (range 10)
▶ 2
▶ 5
▶ 7
▶ 9
▶ 4
```
```elvish
range 10 | sample 5
▶ 1
▶ 0
▶ 6
▶ 8
▶ 5
```
***
## shuffle
```elvish
shuffle (range 10)
▶ 1
▶ 5
▶ 3
▶ 4
▶ 7
▶ 8
▶ 2
▶ 6
▶ 0
▶ 9
```
```elvish
range 10 | shuffle
▶ 2
▶ 1
▶ 7
▶ 6
▶ 4
▶ 8
▶ 0
▶ 9
▶ 5
▶ 3
```
 
# Set functions
***
## union
 
Set theory union
```elvish
union [a b c] [d b e f] [g e h i]
put [a b c] [d b e f] [g e h i] | union
```
```elvish
▶ a
▶ b
▶ c
▶ d
▶ e
▶ f
▶ g
▶ h
▶ i
```
***
## difference
 
Subtracts a bunch of sets from another
```elvish
difference [a b c] [a d e]
▶ b
▶ c
```
```elvish
difference [a b c] [a d e] [b f g]
put [a d e] [b f g] | difference [a b c]
```
```elvish
▶ c
```
***
## disj
 
Like difference, but subtracts individual elements
```elvish
disj [a b c d e f g] d e g
put d e g | disj [a b c d e f g]
```
```elvish
▶ a
▶ b
▶ c
▶ f
```
***
## intersection
 
Set theory intersection - returns only the items in all sets.
```elvish
intersection [a b c]
▶ a
▶ b
▶ c
```
```elvish
intersection [a b c] [b c d]
put [a b c] [b c d] | intersection
```
```elvish
▶ b
▶ c
```
```elvish
intersection [a b c] [b c d] [c d e]
▶ c
```
***
## subset
 
Predicate - returns true if l1 is a subset of l2.  False otherwise
```elvish
subset [a b c] [d e f b a c]
▶ $true
```
```elvish
subset [d e f b a c] [c b a]
▶ $false
```
***
## superset
 
Predicate - returns true if l1 is a superset of l2.  False otherwise
```elvish
superset [d e f b a c] [a b c]
▶ $true
```
```elvish
superset [a b c] [d e f b a c]
▶ $false
```
***
## overlaps
 
Predicate - returns true if l1 & l2 have a non-empty intersection.
```elvish
overlaps [a b c d e f g] [e f g h i j k]
▶ $true
```
```elvish
overlaps [a b c] [d e f]
▶ $false
```
 
# Map functions
***
## update
 
Updates a map element by applying a function to the value.
```elvish
update [&a=1] a $base:inc~
update [&a=0] a $'+~' 2
put 2 | update [&a=0] a $'+~' (one)
put 1 1 | update [&a=0] a $'+~' (all)
```
```elvish
▶ [&a=(num 2)]
```
 
It works on lists, too.
```elvish
update [1 2 2] 0 $base:inc~
▶ [(num 2) 2 2]
```
***
## vals
 
sister fn to `keys`
```elvish
vals [&a=1 &b=2 &c=3]
▶ 1
▶ 2
▶ 3
```
***
## kvs
 
Given [&k1=v1 &k2=v2 ...], returns a sequence of [k1 v1] [k2 v2] ... 
```elvish
kvs [&a=1 &b=2 &c=3]
▶ [a 1]
▶ [b 2]
▶ [c 3]
```
***
## merge
 
Merges two or more maps.
```elvish
merge [&a=1 &b=2] [&c=3] [&d=4]
put [&a=1 &b=2] [&c=3] [&d=4] | merge
```
```elvish
▶ [&a=1 &b=2 &c=3 &d=4]
```
 
Uses the last value if it sees overlaps. Pay attention to the `a` in this example.
```elvish
merge [&a=1 &b=2] [&a=3 &c=4]
▶ [&a=3 &b=2 &c=4]
```
 
Works with zero-length input.
```elvish
merge [&]
merge [&] [&]
```
```elvish
▶ [&]
```
***
## merge-with
 
Like merge, but takes a function which aggregates shared keys.
```elvish
merge-with $'+~' [&a=1 &b=2] [&a=3 &c=4]
put [&a=1 &b=2] [&a=3 &c=4] | merge-with $'+~'
put $'+~' [&a=1 &b=2] [&a=3 &c=4] | merge-with (all)
```
```elvish
▶ [&a=(num 4) &b=2 &c=4]
```
***
## select-keys
 
Returns a map with the requested keys.
```elvish
select-keys [&a=1 &b=2 &c=3] a c
put a c | select-keys [&a=1 &b=2 &c=3]
```
```elvish
▶ [&a=1 &c=3]
```
 
It won't add keys which aren't there.
```elvish
select-keys [&a=1 &b=2 &c=3] a c d e f g
▶ [&a=1 &c=3]
```
 
It also works with lists.
```elvish
select-keys [1 2 3] 0 0 2
▶ [&0=1 &2=3]
```
***
## get-in
 
Returns nested elements.  Nonrecursive.
```elvish
get-in [&a=[&b=[&c=v]]] a b c
put a b c | get-in [&a=[&b=[&c=v]]]
```
```elvish
▶ v
```
 
Works with lists.
```elvish
get-in [0 1 [2 3 [4 v]]] 2 2 1
▶ v
```
 
Returns nothing when not found.
```elvish
get-in [&a=1 &b=2 &c=3] a b c
```
MATCHES EXPECTATIONS: `[nothing]`
***
## assoc-in
 
Nested assoc.  Recursive
```elvish
assoc-in [&] [a b c] v
assoc-in [&a=1] [a b c] v
assoc-in [&a=[&b=1]] [a b c] v
assoc-in [&a=[&b=[&c=1]]] [a b c] v
```
```elvish
▶ [&a=[&b=[&c=v]]]
```
```elvish
assoc-in [&a=1 &b=2] [a b c] v
▶ [&a=[&b=[&c=v]] &b=2]
```
***
## update-in
 
Nested update. Recursive.
```elvish
update-in [&a=[&b=[&c=(num 1)]]] [a b c] $base:inc~
▶ [&a=[&b=[&c=(num 2)]]]
```
 
Returns the map unchanged if not found.
```elvish
update-in [&a=1 &b=2 &c=3] [a b c] $base:inc~
▶ [&a=1 &b=2 &c=3]
```
***
## rename-keys
 
Returns map `m` with the keys in kmap renamed to the vals in kmap
```elvish
rename-keys [&a=1 &b=2] [&a=newa &b=newb]
▶ [&newa=1 &newb=2]
```
 
Won't produce key collisions
```elvish
rename-keys [&a=1 &b=2] [&a=b &b=a]
▶ [&a=2 &b=1]
```
***
## index
 
returns a map with the maps grouped by the given keys
```elvish
index [[&name=betsy &weight=1000] [&name=jake &weight=756] [&name=shyq &weight=1000]] weight
put weight | index [[&name=betsy &weight=1000] [&name=jake &weight=756] [&name=shyq &weight=1000]]
```
```elvish
▶ [&[&weight=1000]=[[&name=betsy &weight=1000] [&name=shyq &weight=1000]] &[&weight=756]=[[&name=jake &weight=756]]]
```
 
# Function modifiers
***
## destruct
 
Works a bit like call, but returns a function.
 
`+` doesn't work with a list...
```elvish
+ [1 2 3]
▶ [&reason=<unknown wrong type of argument 0: must be number>]
```
 
But it does with `destruct`
```elvish
(destruct $'+~') [1 2 3]
▶ 6
```
***
## complement
 
Returns a function which negates the boolean result
```elvish
base:is-odd 1
(complement $base:is-odd~) 2
```
```elvish
▶ $true
```
***
## partial
 
Curries arguments to functions
```elvish
+ 1 2 3
(partial $'+~' 1) 2 3
(partial $'+~' 1 2) 3
put 2 3 | (partial $'+~' 1)
put 1 | partial $'+~' | (one) 2 3
```
```elvish
▶ 6
```
***
## juxt
 
Takes any number of functions and executes all of them on the input
```elvish
(juxt $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ ) 1
put 1 | (juxt $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ )
put $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ | juxt | (one) 1
```
```elvish
▶ 0
▶ 2
▶ $true
▶ $false
```
***
## constantly
 
Takes `@xs`. Returns a function which takes any number of args, and returns `@xs`
 
The builtin will throw an error if you give it input args.
```elvish
(constantly a) 1 2 3
put 1 2 3 | (constantly a) (all)
put a | constantly | (one) 1 2 3
```
```elvish
▶ a
```
```elvish
(constantly [a b c]) 1 2 3
▶ [a b c]
```
```elvish
(constantly a b c) 1 2 3
▶ a
▶ b
▶ c
```
***
## comp
 
Composes functions into a new fn.  Contrary to expectation, works left-to-right.
```elvish
(comp (partial $'*~' 5) (partial $'+~' 5)) 5
put 5 | (comp (partial $'*~' 5) (partial $'+~' 5))
put (partial $'*~' 5) (partial $'+~' 5) | comp | (one) 5
```
```elvish
▶ 30
```
***
## box
 
Returns a function which calls `listify` on the result.  The function must have parameters.
```elvish
(box {|@xs| put $@xs}) 1 2 3
put 1 2 3 | (box {|@xs| put $@xs})
put {|@xs| put $@xs} | box (one) | (one) 1 2 3
```
```elvish
▶ [1 2 3]
```
***
## memoize
 
Caches function results so they return more quickly.  Function must be pure.
```elvish
memoize {|n| sleep 1; * $n 10}
▶ <closure 0xc000b2ac00>
```
 
Here, `$fixtures[f]` is a long running function.
```elvish
time { $fixtures[f] 10 } | all
▶ 100
▶ 1.00086881s
```
```elvish
time { $fixtures[f] 10 } | all
▶ 100
▶ 254.638µs
```
***
## repeatedly
 
Takes a zero-arity function and runs it `n` times
```elvish
repeatedly 10 { randint 1000 }
▶ 308
▶ 404
▶ 674
▶ 905
▶ 627
▶ 538
▶ 807
▶ 541
▶ 362
▶ 141
```
 
# Reduce & company
***
## reduce
 
Reduce does what you expect.
```elvish
reduce $'+~' 1 2 3
put 1 2 3 | reduce $'+~'
put $'+~' 1 2 3 | reduce (all)
```
```elvish
▶ 6
```
 
It's important to understand that `reduce` only returns scalar values.
```elvish
reduce $base:append~ [] 0 1 2
▶ [0 1 2]
```
```elvish
reduce {|a b| assoc $a $@b} [&] [a 1] [b 2]
▶ [&a=1 &b=2]
```
 
You can get around this by using `box`.  `comp` is defined similarly, for instance.
 
A fun thing to try is `reductions` with the following test.  Just remove the call to `all`.
```elvish
all (reduce (box {|a b| each {|x| put $x } $a; put $b }) [] 0 1 2 3 4 5)
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
```
***
## reduce-kv
 
Like reduce, but the provided function params look like `[accumulator key value]` instead of [accumulator value]
 
Most easily understood on a map.  In this example we swap the keys and values.
```elvish
reduce-kv {|a k v| assoc $a $v $k} [&] [&a=1 &b=2 &c=2]
put [&a=1 &b=2 &c=2] | reduce-kv {|a k v| assoc $a $v $k} [&] (one)
```
```elvish
▶ [&1=a &2=c]
```
 
Varargs are treated as an associative list, using the index as the key
```elvish
reduce-kv {|a k v| assoc $a $k $v} [&] a b c
put a b c | reduce-kv {|a k v| assoc $a $k $v} [&] (all)
put [&] a b c | reduce-kv {|a k v| assoc $a $k $v}
```
```elvish
▶ [&(num 0)=a &(num 1)=b &(num 2)=c]
```
 
`reduce-kv` doesn't have to return a map.  Here, we also specify a starting index.
```elvish
reduce-kv &idx=1 {|a k v| + $a (* $k $v)} 0 1 2 3
put 0 1 2 3 | reduce-kv &idx=1 {|a k v| + $a (* $k $v)}
```
```elvish
▶ 14
```
***
## reductions
 
Essentially reduce, but it gives the intermediate values at each step
```elvish
reductions $'+~' 1 2 3
put 1 2 3 | reductions $'+~'
put $'+~' 1 2 3 | reductions (all)
```
```elvish
▶ 1
▶ 3
▶ 6
```
 
# Filter & company
***
## filter
 
Filter does what you expect.  `pfilter` works in parallel.
```elvish
filter $base:is-even~ (range 1 10)
range 1 10 | filter $base:is-even~
```
```elvish
▶ 2
▶ 4
▶ 6
▶ 8
```
 
It treats empty resultsets as $false.
```elvish
filter {|n| if (== (% $n 2) 0) { put $true }} (range 1 10)
▶ 2
▶ 4
▶ 6
▶ 8
```
 
Same with `$nil`.
```elvish
filter {|n| if (== (% $n 2) 0) { put $true } else { put $nil }} (range 1 10)
▶ 2
▶ 4
▶ 6
▶ 8
```
***
## remove
 
Remove does what you expect.  `premove` works in parallel.
```elvish
remove $base:is-odd~ (range 1 10)
range 1 10 | remove $base:is-odd~
```
```elvish
▶ 2
▶ 4
▶ 6
▶ 8
```
 
# "Array" operations
***
## into
 
Shoves some input into the appropriate container.
```elvish
into [] 1 2 3
into [1] 2 3
put 1 2 3 | into []
put [] 1 2 3 | into (all)
```
```elvish
▶ [1 2 3]
```
 
You can also shove into a map
```elvish
into [&] [a 1] [b 2] [c 3]
into [&b=2] [a 1] [c 3]
put [a 1] [b 2] [c 3] | into [&]
```
```elvish
▶ [&a=1 &b=2 &c=3]
```
 
Into takes optional arguments for getting keys/vals from the input.
```elvish
use str; into [&] &keyfn=$put~ &valfn=$str:to-utf8-bytes~ (all stuff)
▶ [&f=0x66 &s=0x73 &t=0x74 &u=0x75]
```
 
Into also takes an optional argument for handling collisions.
```elvish
use str; into [&] &keyfn=$put~ &valfn=(box $str:to-utf8-bytes~) &collision=$base:concat2~ (all stuff)
▶ [&f=[0x66 0x66] &s=[0x73] &t=[0x74] &u=[0x75]]
```
***
## reverse
 
Does what's on the tin.
```elvish
reverse (range 6)
range 6 | reverse
```
```elvish
▶ 5
▶ 4
▶ 3
▶ 2
▶ 1
▶ 0
```
***
## distinct
 
Returns a set of the elements in `@arr`.
 
Does not care about maintaining order.
```elvish
distinct 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5
distinct 1 2 3 2 3 3 4 4 5 5 5 4 4 5 5
put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | distinct
```
```elvish
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
```
 
It doesn't care about mathematical equality
```elvish
distinct 1 1.0 (num 1) (num 1.0)
▶ 1.0
▶ 1
▶ 1.0
▶ 1
```
***
## unique
 
Like `uniq` but works with the data pipe.
```elvish
unique 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5
put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | unique
```
```elvish
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
```
 
Includes an optional `count` parameter.
```elvish
unique &count=$true 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5
put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | unique &count=true
```
```elvish
▶ [(num 1) 1]
▶ [(num 2) 2]
▶ [(num 3) 3]
▶ [(num 4) 4]
▶ [(num 5) 5]
```
 
It doesn't care about mathematical equality
```elvish
unique 1 1.0 (num 1) (num 1.0)
▶ 1
▶ 1.0
▶ 1
▶ 1.0
```
***
## replace
 
Returns an "array" with elements of `coll` replaced according to `smap`.
 
Works with combinations of lists & maps.
```elvish
replace [zeroth first second third fourth] [(num 0) (num 2) (num 4) (num 0)]
▶ zeroth
▶ second
▶ fourth
▶ zeroth
```
```elvish
replace [&2=two &4=four] [4 2 3 4 5 6 2]
▶ four
▶ two
▶ 3
▶ four
▶ 5
▶ 6
▶ two
```
```elvish
replace [&[city london]=[postcode wd12]] [&name=jack &city=london &id=123] | into [&]
▶ [&name=jack &postcode=wd12 &id=123]
```
***
## interleave
 
Returns an "array" of the first item in each list, then the second, etc.
```elvish
interleave [a b c] [1 2 3]
▶ a
▶ 1
▶ b
▶ 2
▶ c
▶ 3
```
 
Understands mismatched lengths
```elvish
interleave [a b c d] [1 2 3]
interleave [a b c] [1 2 3 4]
```
```elvish
▶ a
▶ 1
▶ b
▶ 2
▶ c
▶ 3
```
***
## interpose
 
Returns an "array" of the elements seperated by `sep`.
```elvish
interpose , one
▶ one
```
```elvish
interpose , one two
▶ one
▶ ,
▶ two
```
```elvish
interpose , one two three
▶ one
▶ ,
▶ two
▶ ,
▶ three
```
***
## partition
 
partitions an array into lists of size n.
```elvish
partition 3 (range 12)
range 12 | partition 3
```
```elvish
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
```
 
Drops items which don't complete the specified list size.
```elvish
range 14 | partition 3
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
```
 
Specify `&step=n` to specify a "starting point" for each partition.
```elvish
range 12 | partition 3 &step=5
▶ [(num 0) (num 1) (num 2)]
▶ [(num 5) (num 6) (num 7)]
```
 
`&step` can be < than the partition size.
```elvish
range 4 | partition 2 &step=1
▶ [(num 0) (num 1)]
▶ [(num 1) (num 2)]
▶ [(num 2) (num 3)]
```
 
When there are not enough items to fill the last partition, a pad can be supplied.
```elvish
range 14 | partition 3 &pad=[a]
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12) (num 13) a]
```
 
The size of the pad may exceed what is used.
```elvish
range 13 | partition 3 &pad=[a b]
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12) a b]
```
 
...or not.
```elvish
range 13 | partition 3 &pad=[]
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
partition-all 3 (range 13)
range 13 | partition-all 3
```
```elvish
▶ [(num 0) (num 1) (num 2)]
▶ [(num 3) (num 4) (num 5)]
▶ [(num 6) (num 7) (num 8)]
▶ [(num 9) (num 10) (num 11)]
▶ [(num 12)]
```
***
## iterate
 
Returns an array of `(f x), (f (f x)), (f (f (f x)) ...)`, up to the nth element.
```elvish
iterate $base:inc~ 10 (num 1)
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
▶ 10
```
 
My favorite example of iterate is to generate fibonacci numbers.  In increasingly functional style:
```elvish
iterate {|l| put [$l[1] (+ $l[0] $l[1])]} 10 [(num 1) (num 1)] | each $base:first~
iterate (destruct {|a b| put [$b (+ $a $b)]}) 10 [(num 1) (num 1)] | each $base:first~
iterate (box (destruct (juxt $second~ $'+~'))) 10 [(num 1) (num 1)] | each $base:first~
```
```elvish
▶ 1
▶ 1
▶ 2
▶ 3
▶ 5
▶ 8
▶ 13
▶ 21
▶ 34
▶ 55
```
***
## take-nth
 
Emits every nth element.
```elvish
take-nth 2 (range 10)
range 10 | take-nth 2
```
```elvish
▶ 0
▶ 2
▶ 4
▶ 6
▶ 8
```
***
## take-while
 
Emits items until `(f x)` yields an empty or falsey value.
```elvish
take-while (complement (partial $'<=~' 5)) (range 10)
range 10 | take-while {|n| < $n 5 }
take-while {|n| if (< $n 5) { put $true } } (range 10)
```
```elvish
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
```
***
## drop-while
 
Emits items until `(f x)` yields a non-empty or truthy value.
```elvish
drop-while (complement (partial $'<=~' 5)) (range 10)
range 10 | drop-while {|n| < $n 5 }
drop-while {|n| if (< $n 5) { put $true } } (range 10)
```
```elvish
▶ 5
▶ 6
▶ 7
▶ 8
▶ 9
```
***
## drop-last
 
Drops the last n elements of `@arr`.
```elvish
drop-last 2 (range 10)
range 10 | drop-last 2
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
```
***
## butlast
 
Drops the last element of `@arr`.
```elvish
butlast (range 10)
range 10 | butlast
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
```
 
# Predicate runners
***
## some
 
Returns the first truthy `(f x)`
 
If f is a true predicate (takes an element, returns $true or $false), `some` tells you if at least one (any/some) x satisfies the predicate.
 
Opposite function is `not-any`
```elvish
some (partial $'>~' 5) (range 10)
range 10 | some (partial $'>~' 5)
```
```elvish
▶ $true
```
***
## first-pred
 
`some` is useful for lots of things, but you probably want one of the other functions.
```elvish
first-pred (comp $math:sin~ (partial $'<~' (num 0.9))) (range 10)
range 10 | first-pred (comp $math:sin~ (partial $'<~' (num 0.9)))
```
```elvish
▶ 2
```
***
## every
 
returns true if each x satisfies the predicate.
```elvish
range 20 | each $math:sin~ [(all)] | every {|n| <= -1 $n 1}
▶ $true
```
***
## not-every
 
opposite of `every`.
 
returns true if at least one x fails to satisfy the predicate.
```elvish
range 20 | each $math:sin~ [(all)] | not-every {|n| <= -1 $n 1}
▶ $false
```
***
## not-any
 
opposite of `some`.
 
returns true if none of the elements satisfy the predicate
```elvish
range 20 | each $math:sin~ [(all)] | not-any {|n| > $n 1}
▶ $true
```
 
# Map functions
***
## keep
 
Returns an "array" of non-empty & non-nil results of `(f x)`.  `pkeep` works in parallel.
```elvish
keep {|x| if (base:is-even $x) { put $x }} (range 1 10)
keep {|x| if (base:is-even $x) { put $x } else { put $nil }} (range 1 10)
range 1 10 | keep {|x| if (base:is-even $x) { put $x }}
```
```elvish
▶ 2
▶ 4
▶ 6
▶ 8
```
 
Additionally, you can specify your own predicate function instead.
```elvish
keep (partial $'*~' 3) (range 1 10) &pred=$base:is-even~
▶ 6
▶ 12
▶ 18
▶ 24
```
***
## map
 
`map` is a more powerful than `each`.  It works with "array" values and reads from the pipe.  `pmap` works in parallel.
```elvish
map $base:inc~ (range 5)
range 5 | map $base:inc~
each $base:inc~ [(range 5)]
```
```elvish
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
```
 
Unlike `each`, `map` understands what to do with multiple lists.
```elvish
map $'+~' [1 2 3] [4 5 6] [7 8 9] [10 11 12]
▶ 22
▶ 26
▶ 30
```
 
It also understands mismatches
```elvish
map $'+~' [1 2 3] [4 5 6] [7 8 9] [10 11 12 13 14 15]
▶ 22
▶ 26
▶ 30
```
 
If you can, supply the optional parameters for faster performance.
 
For most operations, `&lists=$false` is enough.
```elvish
map $base:inc~ (range 5) &lists=$false
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
```
 
When working with lists, supply `&els` for faster performance.
```elvish
map $'+~' [1 2 3] [4 5 6] [7 8 9] [10 11 12] &lists=$true &els=3
▶ 22
▶ 26
▶ 30
```
 
`map` can still process multiple lists the way that `each` does.  Just set `&lists=$false`.
```elvish
each $base:first~ [[1 2 3] [4 5 6] [7 8 9]]
map $base:first~ [1 2 3] [4 5 6] [7 8 9] &lists=$false
```
```elvish
▶ 1
▶ 4
▶ 7
```
***
## mapcat
 
Applies concat to the result of `(map f xs)`.  Here for convenience.
```elvish
mapcat (box (destruct $reverse~)) [3 2 1] [6 5 4] [9 8 7] &lists=$false
▶ [1 2 3 4 5 6 7 8 9]
```
 
Here's some shenanigans.  What does it mean?  You decide.
```elvish
mapcat (box $reverse~) [3 2 1] [6 5 4] [9 8 7] &els=(num 3)
▶ [9 6 3 8 5 2 7 4 1]
```
***
## map-indexed
 
Like map but the index is the first parameter
```elvish
map-indexed {|i x| put [$i $x]} (all stuff)
all stuff | map-indexed {|i x| put [$i $x]}
```
```elvish
▶ [(num 0) s]
▶ [(num 1) t]
▶ [(num 2) u]
▶ [(num 3) f]
▶ [(num 4) f]
```
***
## zipmap
 
Returns a map with the keys mapped to the corresponding vals
```elvish
zipmap [a b c] [1 2 3]
▶ [&a=1 &b=2 &c=3]
```
 
Understands mismatches
```elvish
zipmap [a b c d] [1 2 3]
zipmap [a b c] [1 2 3 4]
```
```elvish
▶ [&a=1 &b=2 &c=3]
```
***
## keep-indexed
 
Returns all non-empty & non-nil results of `(f index item)`.
```elvish
keep-indexed {|i x| if (base:is-odd $i) { put $x } else { put $nil }} a b c d e f g
▶ b
▶ d
▶ f
```
 
Of course, this works just as well.
```elvish
map-indexed {|i x| if (base:is-odd $i) { put $x } } a b c d e f g
▶ b
▶ d
▶ f
```
 
And supply your own predicate.
```elvish
keep-indexed {|i x| put [$i $x]} a b c d e f g &pred=(comp $base:first~ $base:is-odd~)
▶ [(num 1) b]
▶ [(num 3) d]
▶ [(num 5) f]
```
 
# Table functions
***
## pivot
 
Tables are an "array" of maps with a non-empty intersection of keys.
 
This function pivots them.
```elvish
   pivot [&name=daniel  &weight=1000 &height=900] ^
     [&name=david   &weight=800  &height=700] ^
       [&name=vincent &weight=600  &height=500]
   put [&name=daniel  &weight=1000 &height=900] ^
     [&name=david   &weight=800  &height=700] ^
       [&name=vincent &weight=600  &height=500] ^
         | pivot
```
```elvish
▶ [&name=weight &david=800 &daniel=1000 &vincent=600]
▶ [&name=height &david=700 &daniel=900 &vincent=500]
```
 
Pivoting adds a new column called `name` and also uses the `name` coumn to identify each row, but this is configurable.
```elvish
   pivot [&foo=daniel  &weight=1000 &height=900] ^
     [&foo=david   &weight=800  &height=700] ^
       [&foo=vincent &weight=600  &height=500] ^
         &from_row=foo &to_row=bar
▶ [&david=800 &daniel=1000 &bar=weight &vincent=600]
▶ [&david=700 &daniel=900 &bar=height &vincent=500]
```

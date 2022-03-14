# base.elv
1. [testing-status](#testing-status)
2. [is-zero](#is-zero)
3. [is-one](#is-one)
4. [evens](#evens)
5. [odds](#odds)
6. [inc](#inc)
7. [dec](#dec)
8. [pos/neg](#pos/neg)
9. [is-functions](#is-functions)
10. [prepend](#prepend)
11. [append](#append)
12. [concat2](#concat2)
13. [pluck](#pluck)
14. [get](#get)
15. [first](#first)
16. [ffirst](#ffirst)
17. [second](#second)
18. [rest](#rest)
19. [end](#end)
20. [butlast](#butlast)
21. [nth](#nth)
22. [is-empty](#is-empty)
23. [check-pipe](#check-pipe)
24. [flatten](#flatten)
25. [min/max](#min/max)
***
## testing-status
98 tests passed out of 98

100% of tests are passing

 
These functions largely assume numbers, lists, and strings.  The list operations are of dubious usefulness for users, however.
 
# Math functions
***
## is-zero
 
works with text, nums, and floats
```elvish
is-zero 0
is-zero (num 0)
is-zero (float64 0)
```
```elvish
▶ $true
```
```elvish
is-zero 1
is-zero (randint 1 100)
is-zero (float64 (randint 1 100))
```
```elvish
▶ $false
```
***
## is-one
 
works with text, nums, and floats
```elvish
is-one 1
is-one (num 1)
is-one (float64 1)
```
```elvish
▶ $true
```
```elvish
is-one 0
is-one (num 0)
is-one (float64 0)
```
```elvish
▶ $false
```
***
## evens
 
only works with strings & nums
```elvish
range -5 6 | each $is-even~
range -5 6 | each $to-string~ | each $is-even~
```
```elvish
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
```
 
fails with floats
```elvish
is-even 5.0
▶ [&reason=<unknown wrong type of argument 0: cannot parse as integer: 5.0>]
```
***
## odds
 
only works with strings & nums
```elvish
range -5 6 | each $is-odd~
range -5 6 | each $to-string~ | each $is-odd~
```
```elvish
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
▶ $false
▶ $true
```
 
fails with floats
```elvish
is-odd 5.0
▶ [&reason=<unknown wrong type of argument 0: cannot parse as integer: 5.0>]
```
***
## inc
 
works with text, nums, and floats
```elvish
range -5 6 | each $inc~
range -5 6 | each $to-string~ | each $inc~
```
```elvish
▶ -4
▶ -3
▶ -2
▶ -1
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
▶ 5
▶ 6
```
```elvish
range -5 6 | each $float64~ | each $inc~
▶ -4.0
▶ -3.0
▶ -2.0
▶ -1.0
▶ 0.0
▶ 1.0
▶ 2.0
▶ 3.0
▶ 4.0
▶ 5.0
▶ 6.0
```
***
## dec
 
works with text, nums, and floats
```elvish
range -5 6 | each $dec~
range -5 6 | each $to-string~ | each $dec~
```
```elvish
▶ -6
▶ -5
▶ -4
▶ -3
▶ -2
▶ -1
▶ 0
▶ 1
▶ 2
▶ 3
▶ 4
```
```elvish
range -5 6 | each $float64~ | each $dec~
▶ -6.0
▶ -5.0
▶ -4.0
▶ -3.0
▶ -2.0
▶ -1.0
▶ 0.0
▶ 1.0
▶ 2.0
▶ 3.0
▶ 4.0
```
***
## pos/neg
 
works with text, nums, and floats
```elvish
each $pos~ [-1 1]
each $neg~ [1 -1]
each $pos~ [(num -1) (num 1)]
each $neg~ [(num 1) (num -1)]
each $pos~ [(float64 -1) (float64 1)]
each $neg~ [(float64 1) (float64 -1)]
```
```elvish
▶ $false
▶ $true
```
 
# Type predicates
***
## is-functions
 
predicate functions for types
```elvish
is-fn { }
is-map [&]
is-list []
is-bool $true
is-number (num 0)
is-string ""
```
```elvish
▶ $true
```
 
lots of things which look like other types are actually strings
```elvish
is-string 1
is-string {}
```
```elvish
▶ $true
```
 
likewise, these look like a number and a function, but they are actually strings
```elvish
is-number 1
is-fn {}
```
```elvish
▶ $false
```
 
# List operations
***
## prepend
 
prepends a scalar value to a list
```elvish
prepend [2 3] 0 1
put [2 3] | prepend (all) 0 1
put 2 3 | prepend [(all)] 0 1
```
```elvish
▶ [0 1 2 3]
```
 
prepend on strings implicitly transforms to list
```elvish
prepend ello h
▶ [h e l l o]
```
***
## append
 
appends a scalar value to a list
```elvish
append [0 1] 2 3
put [0 1] | append (all) 2 3
put 0 1 | append [(all)] 2 3
```
```elvish
▶ [0 1 2 3]
```
 
append on strings implicitly transforms to list
```elvish
append hell o
▶ [h e l l o]
```
***
## concat2
 
concatenate two lists
```elvish
concat2 [0 1] [2 3]
▶ [0 1 2 3]
```
 
concat2 on strings implicitly transforms to list
```elvish
concat2 he llo
▶ [h e l l o]
```
***
## pluck
 
removes the element at a given index from a list.
```elvish
pluck [0 1 x 2 3] 2
put [0 1 x 2 3] | pluck (all) 2
put 0 1 x 2 3 | pluck [(all)] 2
```
```elvish
▶ [0 1 2 3]
```
 
corner-cases
```elvish
put [-1 0 1 2 3] | pluck (all) 0
put [0 1 2 3 4] | pluck (all) 4
```
```elvish
▶ [0 1 2 3]
```
 
pluck on strings implicitly transforms to list
```elvish
pluck x-men 1
▶ [x m e n]
```
***
## get
 
retrieves the element at index i in a list
```elvish
get [0 1 s 2 3] 2
put [0 1 s 2 3] | get (all) 2
put 0 1 s 2 3 | get [(all)] 2
```
```elvish
▶ s
```
 
works on strings, too
```elvish
get string 0
▶ s
```
***
## first
 
retrieves the first element from a list
```elvish
first [0 1 2 3]
put 0 1 2 3 | first [(all)]
```
```elvish
▶ 0
```
 
works on strings, too
```elvish
first "hello"
first hello
```
```elvish
▶ h
```
***
## ffirst
 
nested `first` on a list
```elvish
ffirst [[a b c] 1 2 3]
put [a b c] 1 2 3 | ffirst [(all)]
```
```elvish
▶ a
```
***
## second
 
retrieves the second element from a list
```elvish
second [0 1 2 3]
put 0 1 2 3 | second [(all)]
```
```elvish
▶ 1
```
 
works on strings, too
```elvish
second "hello"
second hello
```
```elvish
▶ e
```
***
## rest
 
drops the first element from a list
```elvish
rest [0 1 2 3]
put 0 1 2 3 | rest [(all)]
```
```elvish
▶ [1 2 3]
```
 
works on strings without coercing the result to a list
```elvish
rest "hello"
rest hello
```
```elvish
▶ ello
```
***
## end
 
retrieves the last element from a list (the end of a list)
```elvish
end [0 1 2 3]
put 0 1 2 3 | end [(all)]
```
```elvish
▶ 3
```
 
works on strings, too
```elvish
end "hello"
end hello
```
```elvish
▶ o
```
***
## butlast
 
drops the last element from a list
```elvish
butlast [0 1 2 3]
put 0 1 2 3 | butlast [(all)]
```
```elvish
▶ [0 1 2]
```
 
works on strings without coercing the result to a list
```elvish
butlast "hello"
butlast hello
```
```elvish
▶ hell
```
 
# More complicated list operations
***
## nth
 
returns the nth item in a list
```elvish
nth [f o o b a r] 3
put f o o b a r | nth [(all)] 3
```
```elvish
▶ b
```
 
and of course it works with strings
```elvish
nth foobar 3
▶ b
```
 
It returns nothing if the index is out of range
```elvish
nth [f o o b a r] 10
```
MATCHES EXPECTATIONS: `[nothing]`
 
You can optionally specify the `not-found` value
```elvish
nth [$nil $nil $nil] 10 &not-found=kaboom
▶ kaboom
```
 
It uses `drop` under the hood, so negative indices just return the 0-index
```elvish
nth [f o o b a r] -10
▶ f
```
***
## is-empty
 
does whats on the tin
```elvish
is-empty []
is-empty ''
```
```elvish
▶ $true
```
***
## check-pipe
 
this is probably the most interesting function here.  it takes input, and if the input is empty, returns whats in the pipe.  Otherwise it returns the input, exploded.
```elvish
check-pipe [1 2 3]
put 1 2 3 | check-pipe []
```
```elvish
▶ 1
▶ 2
▶ 3
```
***
## flatten
 
recursive function which basically performs nested explosions on a list, ignoring lists.
```elvish
flatten [1 [2 3] [4 [[5 [6] 7]] 8 [] [9]]]
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
 
anything else is just returned
```elvish
flatten foobar
▶ foobar
```
 
# Min/max functions
***
## min/max
 
they do whats on the tin, but only compare two numbers, hence the signature
```elvish
min2 1 2
max2 0 1
```
```elvish
▶ 1
```
```elvish
min2 (range 1 3)
max2 (range 0 2)
```
```elvish
▶ 1
```

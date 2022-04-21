use dev/rivendell/test

# currently only work with integers
fn is-even {|n| == (% $n 2) 0 }
fn is-odd {|n| != (% $n 2) 0 }

fn is-zero {|n| == 0 $n }
fn is-one {|n| == 1 $n }
fn dec {|n| - $n 1 }
fn inc {|n| + $n 1 }
fn pos {|n| > $n 0 }
fn neg {|n| < $n 0 }

fn is-fn {|x| eq (kind-of $x) fn }
fn is-map {|x| eq (kind-of $x) map }
fn is-list {|x| eq (kind-of $x) list }
fn is-string {|x| eq (kind-of $x) string }
fn is-bool {|x| eq (kind-of $x) bool }
fn is-number {|x| eq (kind-of $x) number }
fn is-nil {|x| eq $x $nil }

fn prepend {|li @args| put [(put $@args (all $li))] }
fn append  {|li @args| put [(put (all $li) $@args)] }
fn concat2 {|l1 l2| put [(all $l1) (all $l2)] }
fn pluck {|li n| put [(all $li[..$n]) (all $li[(inc $n)..])] }
fn get {|li n| put $li[$n] }
fn first {|li| put $li[0] }
fn ffirst {|li| first (first $li) }
fn second {|li| put $li[1] }
fn rest {|li| put $li[1..] }
fn end {|li| put $li[-1] }
fn is-empty {|li| is-zero (count $li) }
fn butlast {|li| put $li[..(dec (count $li))] }
fn swap {|coll x y| assoc (assoc $coll $x $coll[$y]) $y $coll[$x] }

fn nth {
  |li n &not-found=$false|
  if (and $not-found (> $n (count $li))) {
    put $not-found
  } else {
    drop $n $li | take 1
  }
}

fn check-pipe {
  |li|
  # use when taking @args
  if (is-empty $li) {
    all
  } else {
    put $@li
  }
}

fn flatten {
  |li|
  if (eq (kind-of $li) list) {
    for e $li {
      flatten $e
    }
  } else {
    put $li
  }
}

var tests = [base.elv
  'These functions largely assume numbers, lists, and strings.  The list operations are of dubious usefulness for users, however.'
  '# Math functions'
  [is-zero
   'works with text, nums, and floats'
   (test:is-one $true)
   { is-zero 0 }
   { is-zero (num 0) }
   { is-zero (float64 0) }

   (test:is-one $false)
   { is-zero 1 }
   { is-zero (randint 1 100) }
   { is-zero (float64 (randint 1 100)) }]

  [is-one
   'works with text, nums, and floats'
   (test:is-one $true)
   { is-one 1 }
   { is-one (num 1) }
   { is-one (float64 1) }

   (test:is-one $false)
   { is-one 0 }
   { is-one (num 0)}
   { is-one (float64 0)}]

  [evens
   'only works with strings & nums'
   (test:is-each $false $true $false $true $false $true $false $true $false $true $false)
   { range -5 6 | each $is-even~ }
   { range -5 6 | each $to-string~ | each $is-even~ }

   'fails with floats'
   (test:is-error)
   { is-even 5.0 }]

  [odds
   'only works with strings & nums'
   (test:is-each $true $false $true $false $true $false $true $false $true $false $true)
   { range -5 6 | each $is-odd~ }
   { range -5 6 | each $to-string~ | each $is-odd~ }

   'fails with floats'
   (test:is-error)
   { is-odd 5.0 }]

  [inc
   'works with text, nums, and floats'
   (test:is-each (range -4 7))
   { range -5 6 | each $inc~ }

   (test:is-each (range -4 7))
   { range -5 6 | each $to-string~ | each $inc~ }

   (test:is-each (range -4.0 7))
   { range -5 6 | each $float64~ | each $inc~ }]

  [dec
   'works with text, nums, and floats'
   (test:is-each (range -6 5))
   { range -5 6 | each $dec~ }

   (test:is-each (range -6 5))
   { range -5 6 | each $to-string~ | each $dec~ }

   (test:is-each (range -6.0 5))
   { range -5 6 | each $float64~ | each $dec~ }]

  [pos/neg
   'works with text, nums, and floats'
   (test:is-each $false $true)
   { each $pos~ [-1 1] }
   { each $neg~ [1 -1] }
   { each $pos~ [(num -1) (num 1)] }
   { each $neg~ [(num 1) (num -1)] }
   { each $pos~ [(float64 -1) (float64 1)] }
   { each $neg~ [(float64 1) (float64 -1)] }]

  '# Type predicates'

  [is-functions
   'predicate functions for types'
   (test:is-one $true)
   { is-fn { } }
   { is-map [&] }
   { is-list [] }
   { is-bool $true }
   { is-number (num 0) }
   { is-string "" }
   'lots of things which look like other types are actually strings'
   { is-string 1 }
   { is-string {} }
   'likewise, these look like a number and a function, but they are actually strings'
   (test:is-one $false)
   { is-number 1 }
   { is-fn {} }]

  '# List operations'

  [prepend
   'prepends a scalar value to a list'
   (test:is-one [0 1 2 3])
   { prepend [2 3] 0 1 }
   { put [2 3] | prepend (all) 0 1 }
   { put 2 3 | prepend [(all)] 0 1 }

   'prepend on strings implicitly transforms to list'
   (test:is-one [h e l l o])
   { prepend ello h}]

  [append
   'appends a scalar value to a list'
   (test:is-one [0 1 2 3])
   { append [0 1] 2 3 }
   { put [0 1] | append (all) 2 3 }
   { put 0 1 | append [(all)] 2 3 }

   'append on strings implicitly transforms to list'
   (test:is-one [h e l l o])
   { append hell o}]

  [concat2
   'concatenate two lists'
   (test:is-one [0 1 2 3])
   { concat2 [0 1] [2 3] }

   'concat2 on strings implicitly transforms to list'
   (test:is-one [h e l l o])
   { concat2 he llo }]

  [pluck
   'removes the element at a given index from a list.'
   (test:is-one [0 1 2 3])
   { pluck [0 1 x 2 3] 2 }
   { put [0 1 x 2 3] | pluck (all) 2 }
   { put 0 1 x 2 3 | pluck [(all)] 2 }

   'corner-cases'
   { put [-1 0 1 2 3] | pluck (all) 0 }
   { put [0 1 2 3 4] | pluck (all) 4 }

   'pluck on strings implicitly transforms to list'
   (test:is-one [x m e n])
   { pluck x-men 1 }]

  [get
   'retrieves the element at index i in a list'
   (test:is-one s)
   { get [0 1 s 2 3] 2 }
   { put [0 1 s 2 3] | get (all) 2 }
   { put 0 1 s 2 3 | get [(all)] 2 }
   'works on strings, too'
   { get string 0 }]

  [first
   'retrieves the first element from a list'
   (test:is-one 0)
   { first [0 1 2 3] }
   { put 0 1 2 3 | first [(all)] }

   'works on strings, too'
   (test:is-one h)
   { first "hello" }
   { first hello }]

  [ffirst
   'nested `first` on a list'
   (test:is-one a)
   { ffirst [[a b c] 1 2 3] }
   { put [a b c] 1 2 3 | ffirst [(all)] }]

  [second
   'retrieves the second element from a list'
   (test:is-one 1)
   { second [0 1 2 3] }
   { put 0 1 2 3 | second [(all)] }

   'works on strings, too'
   (test:is-one e)
   { second "hello" }
   { second hello }]

  [rest
   'drops the first element from a list'
   (test:is-each [1 2 3])
   { rest [0 1 2 3] }
   { put 0 1 2 3 | rest [(all)] }

   'works on strings without coercing the result to a list'
   (test:is-one ello)
   { rest "hello" }
   { rest hello }]

  [end
   'retrieves the last element from a list (the end of a list)'
   (test:is-one 3)
   { end [0 1 2 3] }
   { put 0 1 2 3 | end [(all)] }

   'works on strings, too'
   (test:is-one o)
   { end "hello" }
   { end hello }]

  [butlast
   'drops the last element from a list'
   (test:is-each [0 1 2])
   { butlast [0 1 2 3] }
   { put 0 1 2 3 | butlast [(all)] }

   'works on strings without coercing the result to a list'
   (test:is-one hell)
   { butlast "hello" }
   { butlast hello }]

  [is-empty
   'does whats on the tin'
   (test:is-one $true)
   { is-empty [] }
   { is-empty '' }]

  [swap
   'Works on maps'
   (test:is-one [&a=1 &b=2])
   { swap [&a=2 &b=1] a b }

   'Works on lists'
   (test:is-one [a b c])
   { swap [b a c] 0 1 }

   'Works on strings'
   (test:is-one stuff)
   {swap tsuff 0 1}]

  '# More complicated list operations'

  [nth
   'returns the nth item in a list'
   (test:is-one b)
   { nth [f o o b a r] 3 }
   { put f o o b a r | nth [(all)] 3 }

   'and of course it works with strings'
   { nth foobar 3 }

   'It returns nothing if the index is out of range'
   (test:is-nothing)
   { nth [f o o b a r] 10 }

   'You can optionally specify the `not-found` value'
   (test:is-one kaboom)
   { nth [$nil $nil $nil] 10 &not-found=kaboom}

   'It uses `drop` under the hood, so negative indices just return the 0-index'
   (test:is-one f)
   { nth [f o o b a r] -10}]



  [check-pipe
   'this is probably the most interesting function here.  it takes input, and if the input is empty, returns whats in the pipe.  Otherwise it returns the input, exploded.'
   (test:is-each 1 2 3)
   { check-pipe [1 2 3] }
   { put 1 2 3 | check-pipe [] }]

  [flatten
   'recursive function which basically performs nested explosions on a list, ignoring lists.'
   (test:is-each (range 1 10 | each $to-string~))
   { flatten [1 [2 3] [4 [[5 [6] 7]] 8 [] [9]]]}

   'anything else is just returned'
   (test:is-one foobar)
   { flatten foobar }]]

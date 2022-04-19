use dev/rivendell/test
use dev/rivendell/base
use math

fn listify {|@els|
  set @els = (base:check-pipe $els)
  put $els
}

fn update {|coll k f @args|
  assoc $coll $k ($f $coll[$k] $@args) 
}

## Hard to believe this isn't a builtin
fn vals {|m|
  each {|k|
    put $m[$k]
  } [(keys $m)]
}

## This makes maps iterable
fn kvs {|m|
  each {|k|
    put [$k $m[$k]]
  } [(keys $m)]
}

fn destruct {|f|
  put {|x|
    $f (all $x)
  }
}

fn complement {|f|
  put {|@x|
    not ($f $@x)
  }
}

fn partial {|f @supplied|
  set @supplied = (base:check-pipe $supplied)
  put {|@args|
    set @args = (base:check-pipe $args)
    $f $@supplied $@args
  }
}

fn juxt {|@fns|
  set @fns = (base:check-pipe $fns)
  put {|@args|
    set @args = (base:check-pipe $args)
    for f $fns {
      $f $@args
    }
  }
}

fn constantly {|@xs|
  set @xs = (base:check-pipe $xs)
  put {|@_|
    put $@xs
  }
}

fn reduce {|f @arr|
  set @arr = (base:check-pipe $arr)
  var acc = $arr[0]
  for b $arr[1..] {
    set acc = ($f $acc $b)
  }
  put $acc
}

fn reduce-kv {|f @arr &idx=0|
  set @arr = (base:check-pipe $arr)
  var acc = $arr[0]
  var arr = $arr[1..]
  if (and (== (count $arr) 1) ^
          (base:is-map $arr[0])) {
    for k [(keys $@arr)] {
      set acc = ($f $acc $k $@arr[$k])
    }
  } else {
    var k = (num $idx)
    for v $arr {
      set acc = ($f $acc $k $v)
      set k = (base:inc $k)
    }
  }
  put $acc
}

fn reductions {|f @arr|
  set @arr = (base:check-pipe $arr)
  var acc = $arr[0]
  put $acc
  for b $arr[1..] {
    set acc = ($f $acc $b)
    put $acc
  }
}

fn comp {|@fns|
  set @fns = (base:check-pipe $fns)
  put {|@x|
    set @x = (base:check-pipe $x)
    all (reduce {|a b| put [($b $@a)]} $x $@fns)
  }
}

fn box {|f|
  comp $f $listify~
}

fn filter {|f @arr|
  set @arr = (base:check-pipe $arr)
  each {|x|
    var @res = ($f $x)
    if (> (count $res) 0) {
      if $@res {
        put $x
      }
    }
  } $arr
}

fn pfilter {|f @arr|
  set @arr = (base:check-pipe $arr)
  peach {|x|
    var @res = ($f $x)
    if (> (count $res) 0) {
      if $@res {
        put $x
      }
    }
  } $arr
}

fn remove {|f @arr|
  filter (complement $f) $@arr
}

fn premove {|f @arr|
  pfilter (complement $f) $@arr
}

fn into {|container @arr &keyfn=$base:first~ &valfn=$base:second~|
  set @arr = (base:check-pipe $arr)
  if (eq (kind-of $container) map) {
    reduce {|a b|
      assoc $a ($keyfn $b) ($valfn $b)
    } $container $@arr
  } elif (eq (kind-of $container) list) {
    base:concat2 $container $arr
  }
}

fn merge {|@maps|
  set @maps = (base:check-pipe $maps)
  reduce {|a b|
    into $a (kvs $b)
  } [&] $@maps
}

fn merge-with {|f @maps|
  set @maps = (base:check-pipe $maps)
  reduce {|a b|
    reduce {|a b|
      if (has-key $a $b[0]) {
        update $a $b[0] $f $b[1]
      } else {
        assoc $a $b[0] $b[1]
      }
    } $a (kvs $b)
  } [&] $@maps
}

fn reverse {|@arr|
  set @arr = (base:check-pipe $arr)
  var i lim = 1 (base:inc (count $arr))
  while (< $i $lim) {
    put $arr[-$i]
    set i = (base:inc $i)
  }
}

fn distinct {|@args|
  set @args = (base:check-pipe $args)
  into [&] &keyfn=$base:identity~ &valfn=(constantly $nil) $@args | keys (one)
}

fn unique {|@args &count=$false|
  var a
  set a @args = (base:check-pipe $args)
  if $count {
    var i = (num 1)
    for x $args {
      if (not-eq $x $a) {
        put [$i $a]
        set a i = $x 1
      } else {
        set i = (base:inc $i)
      }
    }
    put [$i (base:end $args)]
  } else {
    for x $args {
      if (not-eq $x $a) {
        put $a
        set a = $x
      }
    }
    put (base:end $args)
  }
}

fn concat {|@lists|
  set @lists = (base:check-pipe $lists)
  reduce $base:concat2~ [] $@lists
}

fn min-key {|f @arr|
  set @arr = (base:check-pipe $arr)
  var m = (into [&] $@arr &keyfn=$f &valfn=$base:identity~)
  keys $m | math:min (all) | put $m[(one)]
}

fn max-key {|f @arr|
  set @arr = (base:check-pipe $arr)
  var m = (into [&] $@arr &keyfn=$f &valfn=$base:identity~)
  keys $m | math:max (all) | put $m[(one)]
}

fn some {|f @arr|
  set @arr = (base:check-pipe $arr)
  var res = []
  for a $arr {
    set @res = ($f $a)
    if (> (count $res) 0) {
      if $@res {
        break
      }
    }
  }
  put $@res
}

fn first-pred {|f @arr|
  set @arr = (base:check-pipe $arr)
  var res = []
  for a $arr {
    set @res = ($f $a)
    if (> (count $res) 0) {
      if $@res {
        put $a
        break
      }
    }
  }
}

fn not-every {|f @arr|
  some (complement $f) $@arr
}

fn every {|f @arr|
  not (not-every $f $@arr)
}

fn not-any {|f @arr|
  not (some $f $@arr)
}

fn keep {|f @arr &pred=(complement $base:is-nil~)|
  set @arr = (base:check-pipe $arr)
  each {|x|
    var @fx = ($f $x)
    if (> (count $fx) 0) {
      if ($pred $@fx) {
        put $@fx
      }
    }
  } $arr
}

fn pkeep {|f @arr &pred=(complement $base:is-nil~)|
  set @arr = (base:check-pipe $arr)
  peach {|x|
    var @fx = ($f $x)
    if (> (count $fx) 0) {
      if ($pred $@fx) {
        put $@fx
      }
    }
  } $arr
}

fn map {|f @arr &els=(num 1)|
  set @arr = (base:check-pipe $arr)
  if (and (base:is-number $els) (== $els 1)) {
    each $f $arr
  } elif (base:is-number $els) {
    each {|i|
      each {|l|
        put $l[$i]
      } $arr | $f (all)
    } [(range $els)]
  } else {
    map $f $@arr &els=(each $count~ $arr | math:min (all))
  }
}

fn pmap {|f @arr &els=(num 1)|
  set @arr = (base:check-pipe $arr)
  if (and (base:is-number $els) (== $els 1)) {
    peach $f $arr
  } elif (base:is-number $els) {
    peach {|i|
      each {|l|
        put $l[$i]
      } $arr | $f (all)
    } [(range $els)]
  } else {
    pmap $f $@arr &els=(each $count~ $arr | math:min (all))
  }
}

fn mapcat {|f @arr &els=(num 1)|
  map $f $@arr &els=$els | concat
}

fn map-indexed {|f @arr|
  set @arr = (base:check-pipe $arr)
  var els = (count $arr)
  put [(range $els)] $arr | map $f &els=$els
}

fn keep-indexed {|f @arr &pred=(complement $base:is-nil~)|
  map-indexed {|i x|
    var @fx = ($f $i $x)
    if (> (count $fx) 0) {
      if ($pred $@fx) {
        put $@fx
      }
    }
  } $@arr
}

var tests = [Fun.elv
  '# Misc. functions'
  [listify
   'Captures input and shoves it into a list.'
   (test:is-one [1 2 3])
   { put 1 2 3 | listify }
   { listify 1 2 3 }]

  [concat
   'A more generic version of `base:concat2`, which takes any number of lists'
   (test:is-one [1 2 3 4 5 6 7 8 9])
   { concat [1 2 3] [4 5 6] [7 8 9] }
   { put [1 2 3] [4 5 6] [7 8 9] | concat }]

  [min-key/max-key
   "Returns the x for which `(f x)`, a number, is least, or most."
   "If there are multiple such xs, the last one is returned."
   (test:is-one (num 11))
   { min-key $math:sin~ (range 20) }

   (test:is-one (num 14))
   { max-key $math:sin~ (range 20) }]

  '# Map functions'
  [update
   'Updates a map element by applying a function to the value.'
   (test:is-one [&a=(num 2)])
   { update [&a=1] a $base:inc~ }
   { update [&a=0] a $'+~' 2 }
   { put 2 | update [&a=0] a $'+~' (one) }
   { put 1 1 | update [&a=0] a $'+~' (all) }

   'It works on lists, too.'
   (test:is-one [(num 2) 2 2])
   { update [1 2 2] 0 $base:inc~ }]

  [vals
   'sister fn to `keys`'
   (test:is-each 1 2 3)
   { vals [&a=1 &b=2 &c=3] }]

  [kvs
   'Given [&k1=v1 &k2=v2 ...], returns a sequence of [k1 v1] [k2 v2] ... '
   (test:is-each [a 1] [b 2] [c 3])
   { kvs [&a=1 &b=2 &c=3] }]

  [merge
   'Merges two or more maps.'
   (test:is-one [&a=1 &b=2 &c=3 &d=4])
   { merge [&a=1 &b=2] [&c=3] [&d=4] }
   { put [&a=1 &b=2] [&c=3] [&d=4] | merge }

   'Uses the last value if it sees overlaps. Pay attention to the `a` in this example.'
   (test:is-one [&a=3 &b=2 &c=4])
   { merge [&a=1 &b=2] [&a=3 &c=4] }]

  [merge-with
   'Like merge, but takes a function which aggregates shared keys.'
   (test:is-one [&a=(num 4) &b=2 &c=4])
   { merge-with $'+~' [&a=1 &b=2] [&a=3 &c=4] }
   { put [&a=1 &b=2] [&a=3 &c=4] | merge-with $'+~' }
   { put $'+~' [&a=1 &b=2] [&a=3 &c=4] | merge-with (all) }]

  '# Function modifiers'
  [destruct
   'Works a bit like call, but returns a function.'
   "`+` doesn't work with a list..."
   (test:is-error)
   { + [1 2 3] }

   "But it does with `destruct`"
   (test:is-one (num 6))
   { (destruct $'+~') [1 2 3] }]

  [complement
   'Returns a function which negates the boolean result'
   (test:is-one $true)
   { base:is-odd 1 }
   { (complement $base:is-odd~) 2 }]

  [partial
   'Curries arguments to functions'
   (test:is-one (num 6))
   { + 1 2 3 }
   { (partial $'+~' 1) 2 3 }
   { (partial $'+~' 1 2) 3 }
   { put 2 3 | (partial $'+~' 1) }
   { put 1 | partial $'+~' | (one) 2 3 }]

  [juxt
   'Takes any number of functions and executes all of them on the input'
   (test:is-each (num 0) (num 2) $true $false)
   { (juxt $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ ) 1}
   { put 1 | (juxt $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ )}
   { put $base:dec~ $base:inc~ $base:is-odd~ $base:is-even~ | juxt | (one) 1}]

  [constantly
  'Takes `@xs`. Returns a function which takes any number of args, and returns `@xs`'
  'The builtin will throw an error if you give it input args.'
  (test:is-one a)
  { (constantly a) 1 2 3 }
  { put 1 2 3 | (constantly a) (all) }
  { put a | constantly | (one) 1 2 3 }

  (test:is-one [a b c])
  { (constantly [a b c]) 1 2 3 }

  (test:is-each a b c)
  { (constantly a b c) 1 2 3 }]

  [comp
   'Composes functions into a new fn.  Contrary to expectation, works left-to-right.'
   (test:is-one (num 30))
   { (comp (partial $'*~' 5) (partial $'+~' 5)) 5 }
   { put 5 | (comp (partial $'*~' 5) (partial $'+~' 5)) }
   { put (partial $'*~' 5) (partial $'+~' 5) | comp | (one) 5 }]

  [box
   'Returns a function which calls `listify` on the result.  The function must have parameters.'
   (test:is-one [1 2 3])
   { (box {|@xs| put $@xs}) 1 2 3 }
   { put 1 2 3 | (box {|@xs| put $@xs}) }
   { put {|@xs| put $@xs} | box (one) | (one) 1 2 3 }]

  '# Reduce & company'
  [reduce
   'Reduce does what you expect.'
   (test:is-one (num 6))
   { reduce $'+~' 1 2 3 }
   { put 1 2 3 | reduce $'+~' }
   { put $'+~' 1 2 3 | reduce (all) }

   "It's important to understand that `reduce` only returns scalar values."
   (test:is-one [0 1 2])
   { reduce $base:append~ [] 0 1 2 }
   (test:is-one [&a=1 &b=2])
   { reduce {|a b| assoc $a $@b} [&] [a 1] [b 2] }

   "You can get around this by using `box`.  `comp` is defined similarly, for instance."
   "A fun thing to try is `reductions` with the following test.  Just remove the call to `all`."
   (test:is-each 0 1 2 3 4 5)
   { all (reduce (box {|a b| each {|x| put $x } $a; put $b }) [] 0 1 2 3 4 5) }]

  [reduce-kv
   'Like reduce, but the provided function params look like `[accumulator key value]` instead of [accumulator value]'
   'Most easily understood on a map.  In this example we swap the keys and values.'
   (test:is-one [&1=a &2=c])
   { reduce-kv {|a k v| assoc $a $v $k} [&] [&a=1 &b=2 &c=2] }
   { put [&a=1 &b=2 &c=2] | reduce-kv {|a k v| assoc $a $v $k} [&] (one) }

   'Varargs are treated as an associative list, using the index as the key'
   (test:is-one [&(num 0)=a &(num 1)=b &(num 2)=c])
   { reduce-kv {|a k v| assoc $a $k $v} [&] a b c }
   { put a b c | reduce-kv {|a k v| assoc $a $k $v} [&] (all) }
   { put [&] a b c | reduce-kv {|a k v| assoc $a $k $v} }

   "`reduce-kv` doesn't have to return a map.  Here, we also specify a starting index."
   (test:is-one (num 14))
   { reduce-kv &idx=1 {|a k v| + $a (* $k $v)} 0 1 2 3}
   { put 0 1 2 3 | reduce-kv &idx=1 {|a k v| + $a (* $k $v)} }]

  [reductions
   'Essentially reduce, but it gives the intermediate values at each step'
   (test:is-each 1 (num 3) (num 6))
   { reductions $'+~' 1 2 3 }
   { put 1 2 3 | reductions $'+~' }
   { put $'+~' 1 2 3 | reductions (all)}]

  '# Filter & company'
  [filter
   'Filter does what you expect.  `pfilter` works in parallel.'
   (test:is-each (num 2) (num 4) (num 6) (num 8))
   { filter $base:is-even~ (range 1 10) }
   { range 1 10 | filter $base:is-even~ }

   "It treats empty resultsets as $false."
   { filter {|n| if (== (% $n 2) 0) { put $true }} (range 1 10) }

   "Same with `$nil`."
   { filter {|n| if (== (% $n 2) 0) { put $true } else { put $nil }} (range 1 10) }]

  [remove
   'Remove does what you expect.  `premove` works in parallel.'
   (test:is-each (num 2) (num 4) (num 6) (num 8))
   { remove $base:is-odd~ (range 1 10) }
   { range 1 10 | remove $base:is-odd~ }]

  '# "Array" operations'
  [into
   'Shoves some input into the appropriate container.'
   (test:is-one [1 2 3])
   { into [] 1 2 3 }
   { into [1] 2 3 }
   { put 1 2 3 | into [] }
   { put [] 1 2 3 | into (all) }

   'You can also shove into a map'
   (test:is-one [&a=1 &b=2 &c=3])
   { into [&] [a 1] [b 2] [c 3] }
   { into [&b=2] [a 1] [c 3] }
   { put [a 1] [b 2] [c 3] | into [&] }

   'Into takes optional arguments for getting keys/vals from the input.'
   (test:is-one [&s=0x73 &t=0x74 &u=0x75 &f=0x66])
   { use str; into [&] &keyfn=$base:identity~ &valfn=$str:to-utf8-bytes~ (all stuff) }]

  [reverse
   "Does what's on the tin."
   (test:is-each (num 5) (num 4) (num 3) (num 2) (num 1) (num 0))
   { reverse (range 6) }
   { range 6 | reverse }]

  [distinct
   "Returns a set of the elements in `@arr`."
   "Does not care about maintaining order."
   (test:is-differences-empty 1 2 3 4 5)
   { distinct 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 }
   { distinct 1 2 3 2 3 3 4 4 5 5 5 4 4 5 5 }
   { put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | distinct }

   "It doesn't care about mathematical equality"
   (test:is-differences-empty 1 1.0 (num 1) (num 1.0))
   { distinct 1 1.0 (num 1) (num 1.0) }]

  [unique
   "Like `uniq` but works with the data pipe."
   (test:is-each 1 2 3 4 5)
   { unique 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 }
   { put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | unique }

   'Includes an optional `count` parameter.'
   (test:is-each [(num 1) 1] [(num 2) 2] [(num 3) 3] [(num 4) 4] [(num 5) 5])
   { unique &count=$true 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 }
   { put 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5 | unique &count=true }

   "It doesn't care about mathematical equality"
   (test:is-each 1 1.0 (num 1) (num 1.0))
   { unique 1 1.0 (num 1) (num 1.0) }]

  '# Predicate runners'
  [some
   "Returns the first truthy `(f x)`"
   "If f is a true predicate (takes an element, returns $true or $false), `some` tells you if at least one (any/some) x satisfies the predicate."
   'Opposite function is `not-any`'
   (test:is-one $true)
   { some (partial $'>~' 5) (range 10) }
   { range 10 | some (partial $'>~' 5) }]

  [first-pred
   "`some` is useful for lots of things, but you probably want one of the other functions."
   (test:is-one (num 2))
   { first-pred (comp $math:sin~ (partial $'<~' (num 0.9))) (range 10) }
   { range 10 | first-pred (comp $math:sin~ (partial $'<~' (num 0.9))) }]

  [every
   'returns true if each x satisfies the predicate.'
   (test:is-one $true)
   { range 20 | each $math:sin~ [(all)] | every {|n| <= -1 $n 1} }]

  [not-every
   'opposite of `every`.'
   'returns true if at least one x fails to satisfy the predicate.'
   (test:is-one $false)
   { range 20 | each $math:sin~ [(all)] | not-every {|n| <= -1 $n 1} }]

  [not-any
   'opposite of `some`.'
   'returns true if none of the elements satisfy the predicate'
   (test:is-one $true)
   { range 20 | each $math:sin~ [(all)] | not-any {|n| > $n 1} }]

  '# Map functions'
  [keep
   'Returns an "array" of non-empty & non-nil results of `(f x)`.  `pkeep` works in parallel.'
   (test:is-each (num 2) (num 4) (num 6) (num 8))
   { keep {|x| if (base:is-even $x) { put $x }} (range 1 10) }
   { keep {|x| if (base:is-even $x) { put $x } else { put $nil }} (range 1 10) }
   { range 1 10 | keep {|x| if (base:is-even $x) { put $x }} }

   'Additionally, you can specify your own predicate function instead.'
   (test:is-each (num 6) (num 12) (num 18) (num 24))
   { keep (partial $'*~' 3) (range 1 10) &pred=$base:is-even~ }]

  [map
   '`map` is a more powerful `each`.  It works with "array" values and reads from the pipe.  `pmap` works in parallel.'
   (test:is-each (num 1) (num 2) (num 3) (num 4) (num 5))
   { map $base:inc~ (range 5) }
   { range 5 | map $base:inc~ }
   { each $base:inc~ [(range 5)] }

   "Unlike `each`, `map` understands what to do with multiple lists."
   "For performance reasons, set the optional `els` var when doing this."
   (test:is-each (num 22) (num 26) (num 30))
   { map $'+~' [1 2 3] [4 5 6] [7 8 9] [10 11 12] &els=(num 3) }

   "Set the els to $nil to tell `map` to figure it out."
   (test:is-each (num 12) (num 15) (num 18))
   { map $'+~' [1 2 3] [4 5 6] [7 8 9 10] &els=$nil }

   "`map` can still process multiple lists the way that `each` does.  Just omit the arity."
   (test:is-each 1 4 7)
   { each $base:first~ [[1 2 3] [4 5 6] [7 8 9]] }
   { map $base:first~ [1 2 3] [4 5 6] [7 8 9] }]

  [mapcat
   "Applies concat to the result of `(map f xs)`.  Here for convenience."
   (test:is-one [1 2 3 4 5 6 7 8 9])
   { mapcat (box (destruct $reverse~)) [3 2 1] [6 5 4] [9 8 7] }

   "Here's some shenanigans.  What does it mean?  You decide."
   (test:is-each [9 6 3 8 5 2 7 4 1])
   { mapcat (box $reverse~) [3 2 1] [6 5 4] [9 8 7] &els=(num 3) }]

  [map-indexed
   'Like map but the index is the first parameter'
   (test:is-each [(num 0) s] [(num 1) t] [(num 2) u] [(num 3) f] [(num 4) f])
   { map-indexed {|i x| put [$i $x]} (all stuff) }
   { all stuff | map-indexed {|i x| put [$i $x]} }]

  [keep-indexed
   'Returns all non-empty & non-nil results of `(f index item)`.'
   (test:is-each b d f)
   { keep-indexed {|i x| if (base:is-odd $i) { put $x } else { put $nil }} a b c d e f g }

   'Of course, this works just as well.'
   { map-indexed {|i x| if (base:is-odd $i) { put $x } } a b c d e f g }

   'And supply your own predicate.'
   (test:is-each [(num 1) b] [(num 3) d] [(num 5) f])
   { keep-indexed {|i x| put [$i $x]} a b c d e f g &pred=(comp $base:first~ $base:is-odd~) }]]

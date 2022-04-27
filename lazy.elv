use dev/rivendell/test
use dev/rivendell/base
use dev/rivendell/fun

fn make-iterator {|&init={ } &curr={ } &step={ } &done={ }|
  put [&init=$init
    &curr=$curr
    &step=$step
    &done=$done]
}

fn inf-iterator {|&init={ } &curr={ } &step={ }|
  make-iterator &init=$init &curr=$curr &step=$step &done={ put $false }
}

fn nest-iterator {|iter &init={ } &curr={ } &step={ } &done={ } &exhaust={ }|
  make-iterator ^
  &init={
    nop ($iter[init])
    nop ($init)
  } ^
  &curr=$curr &step=$step ^
  &done={ or ($iter[done]) ($done) }
}

fn is-iterator {|x|
  and (eq (kind-of $x) map) ^
      (has-key $x init) ^
      (has-key $x step) ^
      (has-key $x curr) ^
      (has-key $x done) ^
      (eq (kind-of $x[init]) fn) ^
      (eq (kind-of $x[step]) fn) ^
      (eq (kind-of $x[curr]) fn) ^
      (eq (kind-of $x[done]) fn)
}

fn to-iter {|@arr|
  set @arr = (base:check-pipe $arr)
  var i c

  make-iterator ^
  &init={ set i c = 0 (count $arr) } ^
  &curr={ put $arr[$i] } ^
  &step={ set i = (base:inc $i) } ^
  &done={ >= $i $c }
}

fn cycle {|@arr|
  set @arr = (base:check-pipe $arr)
  var i c

  inf-iterator ^
  &init={ set i c = 0 (count $arr) } ^
  &curr={ put $arr[(% $i $c)] } ^
  &step={ set i = (base:inc $i) }
}

fn iterate {|f seed|
  var x

  inf-iterator ^
  &init={ set x = $seed } ^
  &curr={ put $x } ^
  &step={ set x = ($f $x) }
}

fn nums {|&start=(num 0) &stop=$nil &step=(num 1)|
  var x

  make-iterator ^
  &init={ set x = (num $start) } ^
  &curr={ put $x } ^
  &step={ set x = (+ $x $step) } ^
  &done=(if (eq $stop $nil) {
      put { put $false }
    } elif (> $step 0) {
      put { >= $x $stop }
    } elif (< $step 0) {
      put { <= $x $stop }
  })
}

fn repeatedly {|f|
  inf-iterator &curr={ put ($f) }
}

fn repeat {|@xs|
  inf-iterator &curr={ put $@xs }
}

fn get-iter {|@iter|
  if (base:is-one (count $iter)) {
    put $@iter
  } else {
    one
  }
}

fn prepend {|list @iter|
  # Cleverly avoids conditionals in the `step` function after it's exhausted
  # the `list`

  set iter = (get-iter $@iter)

  # intermediate vars
  var i c get step

  # static vars
  var getiter = { put ($iter[curr]) }
  var getlist = { put $list[$i]}

  var stepiter steplist
  set stepiter = {
    nop ($iter[step])
    put $stepiter
    put $getiter
  }
  set steplist = {
    set i = (base:inc $i)
    if (== $i $c) {
      put $stepiter
      put $getiter
    } else {
      put $steplist
      put $getlist
    }
  }

  # iterator
  nest-iterator $iter ^
  &init={ set i c get step = 0 (count $list) $getlist $steplist } ^
  &curr={ put ($get) } ^
  &step={ set step get = ($step) }
}

fn keep {|f @iter|
  set iter = (get-iter $@iter)
  var x

  var next = {
    while (not ($iter[done])) {
      var @xs = ($f ($iter[curr]))
      nop ($iter[step])
      if (and (not-eq $xs []) (not-eq $xs [$nil])) {
        put $@xs
        break
      }
    }
  }

  nest-iterator $iter ^
  &init={ set @x = ($next) } ^
  &curr={ put $@x } ^
  &step={ set @x = ($next) }
}

fn filter {|f @iter|
  set iter = (get-iter $@iter)
  var x

  var next = {
    while (not ($iter[done])) {
      var @curr = ($iter[curr])
      var @res = ($f $@curr)
      nop ($iter[step])
      if (not-eq $res []) {
        if $@res {
          put $@curr
          break
        }
      }
    }
  }

  nest-iterator $iter ^
  &init={ set @x = ($next) } ^
  &curr={ put $@x } ^
  &step={ set @x = ($next) }
}

fn interleave {|@iters|
  set @iters = (base:check-pipe $iters)
  use builtin
  var xs

  var next = {
    if (fun:not-any {|i| put ($i[done]) } $@iters) {
      builtin:each {|i| put ($i[curr])} $iters
    }
  }

  make-iterator ^
  &init={
    for i $iters { nop ($i[init]) }
    set @xs = ($next)
  } ^
  &curr={ put $xs[0] } ^
  &step={
    set xs = (base:rest $xs)
    if (base:is-empty $xs) {
      builtin:each {|i| nop ($i[step])} $iters
      set @xs = ($next)
    }
  } ^
  &done={ and (base:is-empty $xs) (fun:some {|i| put ($i[done]) } $@iters) }
}

fn unique {|@iter &count=$false &cmp=$eq~|
  set iter = (get-iter $@iter)
  if $count {
    var prev-el
    var el

    var next = {
      if ($iter[done]) {
        put $nil
      } else {
        var i = 0
        var curr = ($iter[curr])
        while (and (not ($iter[done])) ($cmp $curr ($iter[curr]))) {
          nop ($iter[step])
          set i = (base:inc $i)
        }
        put [$curr $i]
      }
    }

    make-iterator ^
    &init={
      nop ($iter[init])
      set prev-el = ($next)
      set el = ($next)
    } ^
    &curr={ put $prev-el } ^
    &step={
      set prev-el = $el
      set el = ($next)
    } ^
    &done={ eq $prev-el $nil }
  } else {
    nest-iterator $iter ^
    &curr={ put ($iter[curr]) } ^
    &step={
      var curr = ($iter[curr])
      while (and (not ($iter[done])) ($cmp $curr ($iter[curr]))) {
        nop ($iter[step])
      }
    }
  }
}

fn partition {|n @iter &step=$nil &pad=$nil|
  set iter = (get-iter $@iter)
  set step = (or $step $n)
  use builtin
  var buffer done

  var read = {|i|
    while (and (not ($iter[done])) (> $i 0)) {
      put ($iter[curr])
      nop ($iter[step])
      set i = (base:dec $i)
    }
    put $i
  }

  var next = (
    if (eq $pad $nil) {
      if (>= $step $n) {
        put {|_|
          var @xs _ = ($read $step)
          set @xs = (builtin:take $n $xs)
          if (< (count $xs) $n) {
            put $nil $true
          } else {
            put $xs $false
          }
        }
      } else {
        put {|buffer|
          var @xs = (drop $step $buffer | take $n)
          var @xs2 i = ($read (- $n (count $xs)))
          if (> $i 0) {
            put $nil $true
          } else {
            put (base:concat2 $xs $xs2) $false
          }
        }
      }
    } else {
      if (>= $step $n) {
        put {|_|
          var @xs i = ($read $step)
          set @xs = (builtin:take $n $xs)
          set i = (- $n (count $xs))
          put (base:concat2 $xs [(builtin:take $i $pad)]) (> $i 0)
        }
      } else {
        put {|buffer|
          var @xs = (drop $step $buffer | take $n)
          var @xs2 i = ($read (- $n (count $xs)))
          put (base:concat2 $xs $xs2 [(builtin:take $i $pad)]) (> $i 0)
        }
      }
  })

  var next-if = (
    if (>= $step $n) {
      put {|buffer done|
        if ($iter[done]) {
          put $nil $true
        } else {
          $next $buffer
        }
      }
    } else {
      put {|buffer done|
        if $done {
          put $nil $true
        } else {
          $next $buffer
        }
      }
    })

  make-iterator ^
  &init={
    nop ($iter[init])
    set buffer done = ($next-if [] $false)
  } ^
  &curr={ put $buffer } ^
  &step={ set buffer done = ($next-if $buffer $done) } ^
  &done={ eq $buffer $nil }
}

fn remove {|f @iter|
  filter (fun:complement $f) (get-iter $@iter)
}

fn take {|n @iter|
  set iter = (get-iter $@iter)
  var i

  nest-iterator $iter ^
  &init={ set i = (num 0) } ^
  &curr={ put ($iter[curr]) } ^
  &step={
    set i = (base:inc $i)
    nop ($iter[step])
  } ^
  &done={ >= $i $n }
}

fn take-while {|f @iter|
  set iter = (get-iter $@iter)

  nest-iterator $iter ^
  &curr={ put ($iter[curr]) } ^
  &step={ nop ($iter[step]) } ^
  &done={ eq ($f ($iter[curr])) $false }
}

fn drop {|n @iter|
  set iter = (get-iter $@iter)
  var i

  nest-iterator $iter ^
  &init={
    set i = $n
    while (and (not ($iter[done])) (> $i 0)) {
      nop ($iter[step])
      set i = (base:dec $i)
    }
  } ^
  &curr={ put ($iter[curr]) } ^
  &step={ nop ($iter[step]) } ^
  &done={ > $i 0 }
}

fn drop-while {|f @iter|
  set iter = (get-iter $@iter)

  nest-iterator $iter ^
  &init={
    while (and (not ($iter[done])) (eq ($f ($iter[curr])) $true)) {
      nop ($iter[step])
    }
  } ^
  &curr={ put ($iter[curr]) } ^
  &step={ nop ($iter[step]) }
}

fn rest {|@iter|
  drop 1 (get-iter $@iter)
}

fn reductions {|f acc @iter|
  set iter = (get-iter $@iter)
  var start = $acc

  nest-iterator $iter ^
  &init={ set acc = $start } ^
  &curr={ put $acc } ^
  &step={
    set acc = ($f $acc ($iter[curr]))
    nop ($iter[step])
  }
}

fn each {|f @iter|
  set iter = (get-iter $@iter)
  nest-iterator $iter ^
  &curr={ $f ($iter[curr]) } ^
  &step={ nop ($iter[step]) }
}

fn map {|f @iters|
  set @iters = (base:check-pipe $iters)
  make-iterator ^
  &init={ for i $iters { nop ($i[init]) } } ^
  &curr={ $f (for i $iters { put ($i[curr]) }) } ^
  &step={ for i $iters { nop ($i[step]) } } ^
  &done={ fun:some {|i| put ($i[done]) } $@iters } ^
}

fn map-indexed {|f @iter|
  map $f (nums) (get-iter $@iter)
}

fn interpose {|sep @iter|
  set iter = (get-iter $@iter)

  var i
  var sep = (repeat $sep)
  var m = [&(num -1)=$sep &(num 1)=$iter]

  nest-iterator $iter ^
  &init={
    set i = (num 1)
    nop ($sep[init])
  } ^
  &curr={ put ($m[$i][curr]) } ^
  &step={
    nop ($m[$i][step])
    set i = (* $i -1)
  }
}

fn blast {|@iter|
  set iter = (get-iter $@iter)
  nop ($iter[init])
  while (not ($iter[done])) {
    put ($iter[curr])
    nop ($iter[step])
  }
}

fn assert-iterator {
  |&fixtures=[&] &store=[&]|
  test:assert iterator {|@reality|
    and (== (count $reality) 1) ^
        (is-iterator $@reality)
  } &name=is-iterator &fixtures=$fixtures &store=$store
}

var tests = [lazy.elv
  'This module allows you to express infinite sequences.  Typically you start by providing input to a generator, then pipe them into any number of iterators, and finally pipe that to a consumer.'
  '# Iterator structure'
  [make-iterator
   'Iterators have five zero-arity functions:'
   '- init: performs any initialization steps.'
   '- step: advances iteration to the next value.'
   '- curr: outputs the next value.'
   '- done: returns a boolean.  `true` if the iterator has been exhusted'
   '`inf-iterator` & `nest-iterator` are convenience wrappers around `make-iterator`.'
   (test:is-map)
   { make-iterator }
   { make-iterator &init={ } &curr={ } &step={ } &done={ } }]

  [is-iterator
   'Simple predicate for iterators.  Runs `done` to be sure it returns a bool.'
   'All of the iterators satisfy this predicate.'
   (assert-iterator)
   { range 10 | to-iter }
   { cycle a b c }
   { iterate $base:inc~ (num 0) }
   { nums }
   { repeatedly { randint 100 } }
   { repeat (randint 100) }
   { to-iter d e f | prepend [a b c] }
   { range 10 | to-iter | take 5 }
   { cycle a b c | reductions $base:append~ [] }
   { use str; nums &start=(num 65) | each $str:from-codepoints~ }
   { nums | keep {|n| if (base:is-even $n) { put $n }} }
   { nums | filter $base:is-even~ }
   { nums | remove $base:is-even~ }
   { map $'+~' (to-iter (range 10)) (to-iter (range 10)) }
   { nums &start=10 &step=10 | map-indexed $'*~' }
   { range 10 | to-iter | drop 5 }
   { interleave (to-iter a b c) (to-iter 1 2 3) }
   { interpose , (range 10 | to-iter ) }
   { unique (to-iter a b b c c c a a a a d) }
   { unique (to-iter a b b c c c a a a a d) &count=$true }
   { nums | take-while {|n| < $n 5} }
   { nums | drop-while {|n| < $n 5} }
   { nums &stop=12 | partition 3 }]

  [init
   'The init function means that iterators should "start over" from the beginning.'
   (test:is-one $true)
   {
     var iter = (range 10 | to-iter)
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (cycle a b c)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (iterate $base:inc~ (num 0))
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (repeatedly { put x })
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (repeat (randint 100))
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (to-iter d e f | prepend [a b c])
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (range 10 | to-iter | take 5)
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (cycle a b c | reductions $base:append~ [])
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     use str
     var iter = (nums &start=(num 65) | each $str:from-codepoints~)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums | keep {|n| if (base:is-even $n) { put $n }})
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums | filter $base:is-even~)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums | remove $base:is-even~)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (map $'+~' (to-iter (range 10)) (to-iter (range 10)))
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (nums &start=10 &step=10 | map-indexed $'*~')
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (range 10 | to-iter | drop 5)
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (interleave (to-iter a b c) (to-iter 1 2 3))
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (interpose , (range 10 | to-iter ))
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (unique (to-iter a b b c c c a a a a d))
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (unique (to-iter a b b c c c a a a a d) &count=$true)
     eq (blast $iter | fun:listify) (blast $iter | fun:listify)
   }
   {
     var iter = (nums | take-while {|n| < $n 5})
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums | drop-while {|n| < $n 5})
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }
   {
     var iter = (nums &stop=12 | partition 3)
     eq (take 10 $iter | blast | fun:listify) (take 10 $iter | blast | fun:listify)
   }]

  '# Generators'
  [to-iter
   'Simplest generator.  Transforms an "array" to an iterator.'
   (test:is-each (range 10))
   { to-iter (range 10) | blast }
   { range 10 | to-iter | blast }]

  [cycle
   'cycles an "array" infinitely.'
   (test:is-each a b c a b c a b c a)
   { cycle a b c | take 10 | blast }
   { put a b c | cycle | take 10 | blast }]

  [iterate
   'Returns an "array" of n, f(n), f(f(n)), etc.'
   (test:is-each (range 10))
   { iterate $base:inc~ (num 0) | take 10 | blast }]

  [nums
   'With no options, starts counting up from 0.'
   (test:is-each (range 10))
   { nums | take 10 | blast }
   'You can tell it to start at a specific value.'
   (test:is-each (range 10 20))
   { nums &start=10 | take 10 | blast }
   'You can specify a step value.'
   (test:is-each (num 0) (num 2) (num 4) (num 6) (num 8))
   { nums &step=2 | take 5 | blast }
   'It can be negative.'
   (test:is-each (range 0 -10))
   { nums &step=-1 | take 10 | blast }
   'Stop values can also be provided, although they offer little value over `range`.'
   (test:is-each (range 10))
   { nums &stop=10 | blast }
   '`nums` returns nothing if the inputs make no sense.'
   (test:is-nothing)
   { nums &step=-1 &stop=10 | blast }]

  [repeatedly
   'Takes a zero-arity function and calls it infinitely.'
   (test:is-count 5)
   { repeatedly { randint 100 } | take 5 | blast }]

  [repeat
   'Returns `x` infinitely'
   (test:is-each x x x x x)
   { repeat x | take 5 | blast }]

  '# High-level iterators'
  [prepend
   'Prepends a list to an iterator'
   (test:is-each a b c d e f)
   { to-iter d e f | prepend [a b c] | blast }]

  [take
   'Like `builtin:take` but for iterators.'
   (test:is-each a b c a b c a b c a)
   { cycle a b c | take 10 | blast }
   { put a b c | cycle | take 10 | blast }
   'Exceeding the length of a nested iterator is handled gracefully.'
   (test:is-each (num 0) (num 1) (num 2) (num 3) (num 4))
   { range 5 | to-iter | take 20 | blast }]

  [drop
   'Like `builtin:drop` but for iterators.'
   (test:is-each (num 5) (num 6) (num 7) (num 8) (num 9))
   { range 10 | to-iter | drop 5 | blast }
   'Dropping more than the nested iterator is handled gracefully.'
   (test:is-nothing)
   { range 10 | to-iter | drop 20 | blast }]

  [rest
   'Drops the first element from the iterator.'
   (test:is-each (num 6) (num 7) (num 8) (num 9))
   { range 10 | to-iter | drop 5 | rest | blast }]

  [reductions
   'Like fun:reductions, but works with iterators.'
   (test:is-each [] [a] [a b] [a b c] [a b c a])
   { cycle a b c | reductions $base:append~ [] | take 5 | blast }]

  [each
   'Like `builtin:each, but works with iterators`.'
   (test:is-each A B C)
   { use str; nums &start=(num 65) | each $str:from-codepoints~ | take 3 | blast }]

  [map
   'Like `each`, but works with multiple iterators.'
   (test:is-each (num 0) (num 2) (num 4) (num 6) (num 8))
   { map $'+~' (to-iter (range 10)) (to-iter (range 10)) | take 5 | blast }
   'Can work like `each`, but you should avoid this because it is less performant.'
   (test:is-each A B C)
   { use str; nums &start=(num 65) | map $str:from-codepoints~ | take 3 | blast }]

  [map-indexed
   'Returns a sequence of `(f index element)`.'
   (test:is-each (num 0) (num 20) (num 60) (num 120) (num 200))
   { nums &start=10 &step=10 | map-indexed $'*~' | take 5 | blast }]

  [keep
   "Returns result of `(f x)` when it's non-nil & non-empty."
   'Notice how these two results are different depending on where you place the `take`.'
   (test:is-each (num 0) (num 2) (num 4) (num 6) (num 8))
   { nums | take 10 | keep {|n| if (base:is-even $n) { put $n }} | blast }
   (test:is-each (num 0) (num 2) (num 4) (num 6) (num 8) (num 10) (num 12) (num 14) (num 16) (num 18))
   { nums | keep {|n| if (base:is-even $n) { put $n }} | take 10 | blast }]

  [filter
   "Returns `x` when `(f x)` is non-empty & truthy."
   (test:is-each (num 0) (num 2) (num 4) (num 6) (num 8))
   { nums | filter $base:is-even~ | take 5 | blast }]

  [remove
   "Returns `x` when `(complement (f x))` is non-empty & truthy."
   (test:is-each (num 1) (num 3) (num 5) (num 7) (num 9))
   { nums | remove $base:is-even~ | take 5 | blast }]

  [interleave
   'Returns a sequence of the first item in each iterator, then the second, etc.'
   (test:is-each a 1 b 2 c 3)
   { interleave (to-iter a b c) (to-iter 1 2 3) | blast }
   'Understands when to stop short.'
   (test:is-each a 1 b 2)
   { interleave (to-iter a b) (to-iter 1 2 3) | blast }
   { interleave (to-iter a b c) (to-iter 1 2) | blast }]

  [interpose
   'Returns the elements from the nested iterator, interposed with `sep`.'
   (test:is-each a , b , c)
   { interpose , (to-iter a b c) | blast }
   'Needs to elements from iter in order to interpose sep.'
   (test:is-each a)
   { interpose , (to-iter a) | blast }]

  [unique
   'Like `uniq` but for iterators.'
   (test:is-each a b c a)
   { unique (to-iter a b b c c c a a a a) | blast }
   (test:is-each a b c a d)
   { unique (to-iter a b b c c c a a a a d) | blast }
   (test:is-each [a (num 1)] [b (num 2)] [c (num 3)] [a (num 4)])
   { unique (to-iter a b b c c c a a a a) &count=$true | blast }
   (test:is-each [a (num 1)] [b (num 2)] [c (num 3)] [a (num 4)] [d (num 1)])
   { unique (to-iter a b b c c c a a a a d) &count=$true | blast }
   'Corner-case test'
   (test:is-each a)
   { unique (to-iter a) | blast }
   (test:is-each [a (num 1)])
   { unique (to-iter a) &count=$true | blast }]

  [take-while
   'Returns elements so long as `(f x)` returns $true.'
   (test:is-each (num 0) (num 1) (num 2) (num 3) (num 4))
   { nums | take-while {|n| < $n 5} | blast}]

  [drop-while
   'Drops elements until `(f x)` returns false.'
   (test:is-each (num 5) (num 6) (num 7) (num 8) (num 9))
   { nums | drop-while {|n| < $n 5} | take 5 | blast }]

  [partition
   "partitions an iterator into lists of size n."
   (test:is-each [(num 0) (num 1) (num 2)] ^
                 [(num 3) (num 4) (num 5)] ^
                 [(num 6) (num 7) (num 8)] ^
                 [(num 9) (num 10) (num 11)])
   { nums &stop=12 | partition 3 | blast }

   "Drops items which don't complete the specified list size."
   { nums &stop=14 | partition 3 | blast }

   'Specify `&step=n` to specify a "starting point" for each partition.'
   (test:is-each [(num 0) (num 1) (num 2)] [(num 5) (num 6) (num 7)])
   { nums &stop=12 | partition 3 &step=5 | blast }

   "`&step` can be < than the partition size."
   (test:is-each [(num 0) (num 1)] [(num 1) (num 2)] [(num 2) (num 3)])
   { nums &stop=4 | partition 2 &step=1 | blast }

   "When there are not enough items to fill the last partition, a pad can be supplied."
   (test:is-each [(num 0) (num 1) (num 2)] ^
                 [(num 3) (num 4) (num 5)] ^
                 [(num 6) (num 7) (num 8)] ^
                 [(num 9) (num 10) (num 11)] ^
                 [(num 12) (num 13) a])
   { nums &stop=14 | partition 3 &pad=[a] | blast }

   "The size of the pad may exceed what is used."
   (test:is-each [(num 0) (num 1) (num 2)] ^
                 [(num 3) (num 4) (num 5)] ^
                 [(num 6) (num 7) (num 8)] ^
                 [(num 9) (num 10) (num 11)] ^
                 [(num 12) a b])
   { nums &stop=13 | partition 3 &pad=[a b] | blast }

   "...or not."
   (test:is-each [(num 0) (num 1) (num 2)] ^
                 [(num 3) (num 4) (num 5)] ^
                 [(num 6) (num 7) (num 8)] ^
                 [(num 9) (num 10) (num 11)] ^
                 [(num 12)])
   { nums &stop=13 | partition 3 &pad=[] | blast }]

  '# consumers'
  [blast
   'Simplest consumer.  "Blasts" the iterator output to the terminal.'
   (test:is-each (range 10))
   { range 10 | to-iter | blast }]]

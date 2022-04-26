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
   { unique (to-iter a b b c c c a a a a d) &count=$true }]

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

  '# consumers'
  [blast
   'Simplest consumer.  "Blasts" the iterator output to the terminal.'
   (test:is-each (range 10))
   { range 10 | to-iter | blast }]]

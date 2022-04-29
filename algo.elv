use ./test t
use ./base b
use ./lazy l
use ./fun f
use math m
use str s

var fibs = (l:iterate (f:destruct {|x y| put [$y (+ $x $y)]}) [(num 1) (num 1)] | l:each $b:first~)

fn primes {

  var enqueue = {|sieve n step|
    var k = (+ $n $step)
    while (has-key $sieve $k) {
      set k = (+ $k $step)
    }
    assoc $sieve $k $step
  }

  var next-sieve = {|sieve k|
    if (has-key $sieve $k) {
      var step = $sieve[$k]
      set sieve = (dissoc $sieve $k)
      $enqueue $sieve $k $step
    } else {
      $enqueue $sieve $k (+ $k $k)
    }
  }

  var next-primes = {|sieve @seed|
    var k = $@seed
    set sieve = ($next-sieve $sieve $k)
    set k = (+ $k 2)
    while (has-key $sieve $k) {
      set sieve = ($next-sieve $sieve $k)
      set k = (+ $k 2)
    }
    put [$sieve $k]
  }

  l:iterate (f:destruct $next-primes) [[&] (num 3)] ^
  | l:each $b:second~ ^
  | l:prepend [(num 2)]

}

fn line-count {|@files|
  set @files = (b:check-pipe $files)
  each {|file|
    wc -l $file ^
    | s:trim (one) ' ' ^
    | s:split ' ' (one) ^
    | {|n f| put [(num $n) $f]} (all)
  } $files
}

fn lines {|f &follow=$false|
  if $follow {
    l:make-iterator ^
    &curr={ tail -n 0 -f $f | sed '1q;d' | one } ^
    &done={ put $false }
  } else {
    var i

    l:make-iterator ^
    &init={ set i = (num 1) } ^
    &curr={ sed {$i}'q;d' $f } ^
    &step={ set i = (b:inc $i) } ^
    &done={ > $i (b:first (line-count $f)) }
  }
}

fn levenshtein {|w1 w2|
  var cell-value = {|same-char prev-row cur-row col-idx|
    m:min (b:inc $prev-row[$col-idx]) ^
          (b:inc (b:end $cur-row)) ^
          (+ (if $same-char { put (num 0) } else { put (num 1) }) ^
             $prev-row[(b:dec $col-idx)])
  }

  var row-idx = (num 1)
  var max-rows = (b:inc (count $w2))
  var @prev-row = (range (b:inc (count $w1)))

  while (!= $row-idx $max-rows) {
    var ch2 = $w2[(b:dec $row-idx)]
    set row-idx = (b:inc $row-idx)
    set prev-row = (f:reduce {|cur-row i|
        var same-char = (eq $w1[(b:dec $i)] $ch2)
        b:append $cur-row ($cell-value $same-char $prev-row $cur-row $i)
    } [$row-idx] (range 1 (count $prev-row)))
  }

  b:end $prev-row
}

var tests = [algo.elv
  'Miscelaneous algorithms and generators to showcase rivendell.  May not be useful.'
  [fibs
   'This is a var that represents an infinite list of fibonacci numbers.'
   (t:assert-each (each $num~ [1 1 2 3 5 8 13 21 34 55]))
   { l:take 10 $fibs | l:blast }]

  [primes
   'Function which returns an iterator which represents an infinite list of primes.'
   (t:assert-each (each $num~ [2 3 5 7 11 13 17 19 23 29]))
   { l:take 10 (primes) | l:blast }]

  [levenshtein
   'basic levenshtein function to measure the distance between two strings.'
   (t:assert-one (num 0))
   { levenshtein hello hello }
   (t:assert-one (num 4))
   { levenshtein hello world }]]

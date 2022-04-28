use re
use str
use math
use dev/rivendell/base
use dev/rivendell/test
use dev/rivendell/fun

fn is-unicode {|s|
  != (count $s) (wcswidth $s)
}

fn is-ascii {|s|
  == (count $s) (wcswidth $s)
}

fn substr {|s &from=(num 0) &to=$nil|
  var c = (all $s | count)
  set to = (or $to $c)
  if (is-ascii $s) {
    put {$s}[{$from}..{$to}]
  } else {
    if (< $from 0) {
      set from = (+ $c $from)
    }
    if (< $to 0) {
      set to = (+ $c $to)
    }
    set to = (- $to $from)
    drop $from $s | take $to | str:join ''
  }
}

fn trunc {|n s|
  if (<= (wcswidth $s) $n) {
    put $s
  } elif (>= (wcswidth $s[0]) $n) {
    put …
  } elif (is-ascii $s) {
    put {$s[..{$n}]}'…'
  } else {
    set n = (base:dec $n)
    set s = (
      fun:reduce-while ^
      {|a b|
        <= (+ $a[0] (wcswidth $b)) $n
      } ^
      {|a b|
        put [(+ $a[0] (wcswidth $b)) {$a[1]}{$b}]
      } [0 ''] (all $s))
    put {$s[1]}'…'
  }
}

fn lpad {|n s &char=' '|
  var l = (- $n (wcswidth $s) | exact-num (one))
  if (> $l 0) {
    var pad = (repeat $l $char | str:join '')
    put {$pad}{$s}
  } else {
    put $s
  }
}

fn rpad {|n s &char=' '|
  var l = (- $n (wcswidth $s) | exact-num (one))
  if (> $l 0) {
    var pad = (repeat $l $char | str:join '')
    put {$s}{$pad}
  } else {
    put $s
  }
}

fn center {|n s &char=' '|
  var l = (- $n (wcswidth $s) | exact-num (one))
  if (> $l 0) {
    var front = (/ $l 2 | math:trunc (one) | exact-num (one))
    var rear = (- $l $front)
    set front = (repeat $front $char | str:join '')
    set rear = (repeat $rear $char | str:join '')
    put {$front}{$s}{$rear}
  } else {
    put $s
  }
}

var tests = [rune.elv
  'Hosts functions which operate on text.  Tries to behave sanely with variable-width characters.'
  [is-unicode/is-ascii
   'predicates which tell you whether or not the string uses wide characters.'
   (test:is-one $true)
   { is-ascii hello }
   { is-unicode '你好，世界' }
   (test:is-one $false)
   { is-unicode hello }
   { is-ascii '你好，世界' }]

  [substr
   'produces a substring.'
   'returns the string with no options.'
   (test:is-one hello)
   { substr hello }
   (test:is-one '你好，世界')
   { substr '你好，世界' }

   'starts at 0 when `from` is not provided'
   (test:is-one he)
   { substr hello &to=2 }
   (test:is-one '你好')
   { substr '你好，世界' &to=2 }

   'goes to the end of the string when `to` is not provided.'
   (test:is-one ello)
   { substr hello &from=1 }
   (test:is-one '好，世界')
   { substr '你好，世界' &from=1 }

   'feel free to mix them.'
   (test:is-one el)
   { substr hello &from=1 &to=3 }
   (test:is-one '好，')
   { substr '你好，世界' &from=1 &to=3 }

   'negative indices can be provided.'
   (test:is-one ello)
   { substr hello &from=-4 }
   (test:is-one '好，世界')
   { substr '你好，世界' &from=-4 }

   'positive and negative indices can be mixed.'
   (test:is-one ell)
   { substr hello &from=1 &to=-1}
   (test:is-one '好，世')
   { substr '你好，世界' &from=1 &to=-1 }]

  [trunc
   'truncates a string to a specified screen width.'
   (test:is-one 'hello, wo…')
   { trunc 9 'hello, world' }
   (test:is-one '你好，世…')
   { trunc 9 '你好，世界' }
   'a sufficient width will return the whole string.'
   (test:is-one 'hello, world')
   { trunc 12 'hello, world' }
   (test:is-one '你好，世界')
   { trunc 10 '你好，世界' }
   'a width too small will just return the elipsis.'
   (test:is-one …)
   { trunc 1 'hello, world' }
   { trunc 2 '你好，世界' }]

  [lpad/rpad
   'Pads a string to width `n`.  By default, the padding char is a space.'
   'Only works if the padding char is single-width.'
   (test:is-one 'hello..........')
   { rpad 15 hello &char=. }
   (test:is-one '你好，世界.....')
   { rpad 15 '你好，世界' &char=. }
   (test:is-one '..........hello')
   { lpad 15 hello &char=. }
   (test:is-one '.....你好，世界')
   { lpad 15 '你好，世界' &char=. }]

  [center
   'Pads a string on both sides, to width `n`.  If the string is odd width, offsets to the left.'
   'By default, the padding char is a space.'
   'Only works if the padding char is single-width.'
   (test:is-one '..你好，世界...')
   { center 15 '你好，世界' &char=. }
   (test:is-one '.....world.....')
   { center 15 'world' &char=. }]]

use str
use re
use ./base
use ./fun
use ./num

fn substr [from to s]{
  c = (count $s)
  w = (wcswidth $s)
  if (== $c $w) {
    put {$s}[{$from}:{$to}]
  } else {
    if (< $to 0) {
      to = (+ $w $to)
    }
    drop $from $s | take $to | joins ''
  }
}

fn truncatestr [n s]{
  w = (wcswidth $s)

  if (or (<= $w $n) (<= $w 3)) {
    put $s
  } elif (<= $n 3) {
    put ...
  } else {
    ts = (if (== $w (count $s)) {
      put $s[:(- $n 3)]
    } else {
      take $n $s | joins ''
    })
    put {$ts}...
  }
}

fn lpad [n s &char=" "]{
  l = (- $n (wcswidth $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $pad $s | joins ''
  } else {
    put $s
  }
}

fn rpad [n s &char=" "]{
  l = (- $n (wcswidth $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $s $pad | joins ''
  } else {
    put $s
  }
}

fn center [n s &char=" "]{
  l = (- $n (wcswidth $s))
  if (> $l 0) {
    front = (num:truncatef64 (/ $l 2))
    back = (- $l $front)
    put (repeat $front $char) $s (repeat $back $char) | joins ''
  } else {
    put $s
  }
}

fn fast-cell-format [cols s]{
  explode $s | 
    fun:partition-all $cols (all) |
    each (fun:comp (fun:partial $rpad~ $cols) (fun:partial $joins~ ''))
}

fn cell-format [cols s &brk=[' ' '-']]{

  words = (fun:reduce [a b]{
      @a = (each [x]{
          @words = (re:split {$b}+ $x)
          if (> (count $words) 1) {
            for w (base:butlast $words) {
              put {$w}{$b}
            }
            put $words[-1]
          } else {
            explode $words
          }
        } $a)
      put $a
    } [$s] $@brk)

  fold-fn = [a b]{
      b-stripped = (str:trim-right $b ' ')

      # switched to stateful var for perf
      chars = (fun:reduce [a b]{ + $a (wcswidth $b) } 0 (explode $a[-1]))

      word newline = (if (<= (+ $chars (wcswidth $b)) $cols) {
          put $b $false
        } elif (<= (+ $chars (wcswidth $b-stripped)) $cols) {
          put $b-stripped $false
        } else {
          put $b $true
        })

      @parts = (explode $word |
          fun:partition-all $cols (all) |
          each (fun:partial $joins~ '') |
          fun:take-while (fun:partial $not-eq~ ' ') (all))

      if (base:is-one (count $parts)) {
        if $newline {
          a = (base:append $a '')
        }
        a = (fun:update $a -1 [a b]{ joins '' [$a $b] } $parts[0])
      } else {
        for p $parts {
          if (not-eq $a[-1] '') {
            a = (base:append $a '')
          }
          if (not-eq $p ' ') {
            a = (fun:update $a -1 [a b]{ joins '' [$a $b] } $p)
          }
        }
      }

      put $a
    }

  fun:reduce $fold-fn [''] $@words | 
      each (fun:partial $rpad~ $cols) (all)
}

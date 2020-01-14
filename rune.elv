use str
use re
use ./base
use ./fun
use ./num

fn truncatestr [n s]{
  put $s[:(fun:min $n (count $s))]
}

fn lpad [n s &char=" "]{
  l = (- $n (count $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $pad $s | joins ''
  } else {
    put $s
  }
}

fn rpad [n s &char=" "]{
  l = (- $n (count $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $s $pad | joins ''
  } else {
    put $s
  }
}

fn center [n s &char=" "]{
  l = (- $n (count $s))
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

  @words = (fun:reduce [a b]{
      @a = (each [x]{
          @words = (re:split $b+ $x)
          if (> (count $words) 1) {
            @tween = (repeat (count $words) $b)
            fun:interleave $words $tween | fun:butlast
          } else {
            explode $words
          }
        } $a)
      put $a
    } [$s] $@brk | explode (all) |
      fun:partition-all 2 (all) |
      each (fun:partial $joins~ ''))

  fold-fn = [a b]{
      b-stripped = (str:trim-right $b ' ')
      chars = (fun:reduce [a b]{ + $a (count $b) } 0 (explode $a[-1]))

      word newline = (if (<= (+ $chars (count $b)) $cols) {
          put $b $false
        } elif (<= (+ $chars (count $b-stripped)) $cols) {
          put $b-stripped $false
        } else {
          put $b $true
        })

      @parts = (explode $word | 
          fun:partition-all $cols (all) |
          each (fun:partial $joins~ ''))

      if (base:is-one (count $parts)) {
        if $newline {
          a = (base:append $a [])
        }
        a = (fun:update $a -1 $base:append~ $parts[0])
      } else {
        for p $parts {
          if (not (base:is-empty $a[-1])) {
            a = (base:append $a [])
          }
          if (not (eq $p ' ')) {
            a = (fun:update $a -1 $base:append~ $p)
          }
        }
      }

      put $a
    }

  fun:reduce $fold-fn [[]] $@words |
        explode (all) |
        each (fun:comp (fun:partial $rpad~ $cols) (fun:partial $joins~ ''))
}

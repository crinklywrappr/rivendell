use re
use str
use ./base
use ./fun
use ./num
use ./rune

fn sparky [@args &min=$false &max=$false]{
  @args = (base:check-pipe $args)
  ref = [▁ ▂ ▃ ▄ ▅ ▆ ▇ █]

  min = (or $min (fun:min $@args))
  max = (or $max (fun:max $@args))
  sz = (/ (- $max $min) (base:dec (count $ref)))
  
  @sparks = (each [a]{
    if (< $a $min) {
      put ' '
    } elif (> $a $max) {
      put █
    } else {
      idx = (num:truncatef64 (/ (- $a $min) $sz))
      put $ref[$idx]
    }
  } $args)

  joins '' $sparks
}

fn barky [m &formatter=$rune:lpad~
          &pad-char=" " &bar-char=█ 
          &max-cols=80 &desc-pct=.2
          &min=$false &max=$false]{

  if (not (< 0 $desc-pct 1)) {
    put "invalid description size"
    return
  }

  cols = (fun:min $max-cols (float64 (tput cols)))
  desc-room = (* $desc-pct $cols | 
      base:dec (all) |
      num:truncatef64 (all) |
      fun:max 1 (all))

  @kvs = (fun:kvs $m)

  m2 = (fun:reduce [a b]{
    a = (assoc $a min (fun:min $a[min] $b[1]))
    a = (assoc $a max (fun:max $a[max] $b[1]))
    k = (rune:truncatestr $desc-room $b[0] | 
        $formatter $desc-room (all) &char=$pad-char)
    a = (fun:assoc-in $a [m $k] (num:truncatef64 $b[1]))
    put $a
  } [&min=0 &max=0 &m=[&]] $@kvs)

  min = (or $min $m2[min])
  max = (or $max $m2[max])
  @kvs = (fun:kvs $m2[m])
  bar-room = (- $cols $desc-room 1)
  unitsz = (/ $bar-room (- $max $min))

  each (fun:destruct [k v]{
    if (< $v $min) {
      echo $k
    } elif (> $v $max) {
      bar = (repeat $bar-room $bar-char | joins '')
      put $k $bar | joins ' ' | echo (all)
    } else {
      n = (num:truncatef64 (* (- $v $min 1) $unitsz))
      bar = (repeat $n $bar-char | joins '')
      put $k $bar | joins ' ' | echo (all)
    }
  }) $kvs
}

formatter = [&!!float64=$rune:lpad~
             &fn=$rune:center~
             &bool=$rune:center~
             &list=$rune:center~
             &map=$rune:center~
             &nil=$rune:rpad~]

fn is-float64-string [x]{
  try {
    nop (float64 (str:trim-left $x ' '))
    put $true 
  } except {
    put $false 
  }
}

fn is-fn-string [x]{
  or (re:match '^\ *fn\ *$' $x) (re:match '^\ *\(\)=>.*$' $x)
}

fn is-bool-string [x]{
  re:match '^\ *[tf]\ *$' $x
}

fn is-list-string [x]{
  re:match '^\ *\[[0-9]+ items\]\ *$' $x
}

fn is-map-string [x]{
  re:match '^\ *\[&[0-9]+ items\]\ *$' $x
}

fn is-nil-string [x]{
  re:match '^\ *$' $x
}

# TODO: test
fn rep [x &cols=$false &typ=$false &eval=$false]{

  typ f = (if (has-key $formatter $typ) {
        if (base:is-string $x) {
          put string
        } else {
          put $typ
        }
        put $formatter[$typ]
      } elif (has-key $formatter (kind-of $x)) {
        put (kind-of $x) $formatter[(kind-of $x)]
      } else {
        put string
        if (is-nil-string $x) {
          put $formatter[nil]
        } elif (is-list-string $x) {
          put $formatter[list]
        } elif (is-map-string $x) {
          put $formatter[map]
        } elif (is-bool-string $x) {
          put $formatter[bool]
        } elif (is-fn-string $x) {
          put $formatter[fn]
        } elif (is-float64-string $x) {
          put $formatter[!!float64]
        } else {
          put $rune:rpad~
        }
      })

  s = (if (eq $typ !!float64) {
        to-string $x
      } elif (and $eval (eq $typ fn)) {
        r = $x
        while (eq (kind-of $r) fn) {
          r = ($r)
        }
        joins '' ['()=>' $r]
      } elif (eq $typ fn) {
        put fn
      } elif (and (eq $typ bool) $x) {
        put t
      } elif (and (eq $typ bool) (not $x)) {
        put f
      } elif (eq $typ list) {
        joins '' ['[' (count $x) ' items]']
      } elif (eq $typ map) {
        joins '' ['[&' (count $x) ' items]']
      } elif (eq $typ nil) {
        put ''
      } else {
        x = (str:trim $x ' ')
        if $cols {
          rune:truncatestr $cols $x
        } else {
          put $x
        }
      })

  $f (or $cols 0) $s
}

fn row [@xs &sep=" "]{
  @xs = (base:check-pipe $xs)

  f = [a b typ cols]{
        b = (rep $b &typ=$typ &cols=$cols)
        put {$a}' '{$b}' '{$sep}
      }

  s = (fun:reduce [a b]{
    $f $a $b[0] $b[1] $b[2]
  } (chr 0x2502) $@xs)

  # base:butlast does not work due
  # to unicode indexing problem
  #put (base:butlast $s)(chr 0x2502)
  put (explode $s | fun:butlast | joins '')(chr 0x2502)
}

fn sheety [@ms &keys=$false &eval=$false]{

  f = [a k v]{

    typ = (kind-of $v)
    rep = (rep $v &typ=$typ)
    cols = (count $rep)

    if (not (has-key $a[meta] $k)) {
      cols = (base:max2 $cols (count $k))
      a = (fun:assoc-in $a [meta $k] [$typ $cols])
    } else {
      a = (fun:update-in $a [meta $k 1] $base:max2~ $cols)
    }

    fun:assoc-in $a [rows -1 $k] $rep

  }

  x = (fun:reduce [a b]{
        if (not (base:is-empty $a[rows][-1])) {
          a = (fun:update $a rows $base:append~ [&])
        }
        if $keys {
          for k $keys {
            if (has-key $b $k) {
              a = ($f $a $k $b[$k])
            } else {
              a = (fun:assoc-in $a [meta $k] [(kind-of $k) (count $k)])
            }
          }
        } else {
          for k [(keys $b)] {
            a = ($f $a $k $b[$k])
          }
        }
        put $a
      } [&meta=[&] &rows=[[&]]] $@ms)

  max-cols = (tput cols)
  tbl-cols = (count [(keys $x[meta])])
  max-cols = (- $max-cols (base:inc $tbl-cols)) # subtract dividers
  row-width = (/ $max-cols $tbl-cols)

  if (< $row-width 3) {
    put "table too wide for terminal"
    return
  }

  meta2 = (fun:reduce [a b]{
        cols = $x[meta][$b][1]
        if (< $cols $row-width) {
          a = (fun:update $a cnt $base:inc~)
          a = (fun:update $a tot $+~ $cols 2) # account for spacing
        }
        put $a
      } [&tot=0 &cnt=0] (keys $x[meta]))

  # Inf+ if nothing needs to be resized
  remaining = (/ (- $max-cols $meta2[tot]) \
                 (- $tbl-cols $meta2[cnt]))
  remaining = (- $remaining 2) # account for spacing

  if (< $remaining 3) {
    put "table too wide for terminal"
    return
  }

  meta = $x[meta]
  tot-cols = 0

  for k [(keys $meta)] {
    curr = $meta[$k][1]
    cell-cols = (base:min2 $curr $remaining)
    meta = (fun:assoc-in $meta [$k 1] $cell-cols)
    tot-cols = (+ $tot-cols $cell-cols 3)
  }
  tot-cols = (base:dec $tot-cols)

  @border = (repeat $tot-cols (chr 0x2500))

  put (chr 0x256d) $@border (chr 0x256e) | 
    joins '' [(all)] |
    echo (all)

  each [k]{
    typ cols = (explode $meta[$k])
    put [$k $typ $cols]
  } [(keys $meta)] | row &sep=(chr 0x2502) | each $echo~

  put (chr 0x2502) ' ' (repeat (- $tot-cols 2) (chr 0x2500)) ' ' (chr 0x2502) | 
    joins '' [(all)] |
    echo (all)

  for m $x[rows] {
    each [k]{
      typ cols = (explode $meta[$k])
      if (has-key $m $k) {
        put [$m[$k] $typ $cols]
      } else {
        put [$nil nil $cols]
      }
    } [(keys $meta)] | row | echo (all)
  }

  put (chr 0x2570) $@border (chr 0x256f) | 
    joins '' [(all)] |
    echo (all)
}

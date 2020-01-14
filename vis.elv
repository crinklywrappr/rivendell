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
fn rep [x &typ=$false &padding=0 &eval=$false]{

  typ f = (if (has-key $formatter $typ) {
        put $typ $formatter[$typ]
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
        str:trim $x ' '
      })

  $f $padding $s
}

fn sheety [@ms &eval=$false]{

  # format text, get sizes
  x = (fun:reduce [a b]{
        m = (each (fun:box (fun:destruct [k v]{
                nv = (rep $v &eval=$eval)
                nsz = (if (has-key $a[sz] $k) {
                      fun:max (fun:get-in $a sz $k) (count $nv)
                    } else {
                      fun:max (count $k) (count $nv)
                    })
                a = (fun:assoc-in $a [sz $k] $nsz)
                put $k $nv
              })) [(fun:kvs $b)] | fun:into [&] (all))
        fun:update $a ms $base:append~ $m
      } [&sz=[&] &ms=[]] $@ms)

  sz = $x[sz]
  ms = $x[ms]

  ex-padding = (* (base:dec (count $sz)) 3) 
  width = (+ 4 $ex-padding (fun:reduce $+~ (fun:vals $sz)))

  div = (chr 0x2502)

  # header
  put (chr 0x256d) (repeat (- $width 2) (chr 0x2500)) (chr 0x256e) | joins '' | echo (all)
  each (fun:destruct [k v]{
         put ' ' (rep $k &padding=$v) ' ' $div
      }) [(fun:kvs $sz)] |
    fun:listify |
    base:prepend (all) $div |
    explode (all) |
    joins '' |
    echo (all)
  put $div ' ' (repeat (- $width 4) (chr 0x2500)) ' ' $div | joins '' | echo (all)

  # data
  each [m]{
    each (fun:destruct [k v]{
          if (has-key $m $k) {
            put ' ' (rep $m[$k] &padding=$v) '  '
          } else {
            put (repeat (base:inc $v) ' ') '  '
          }
        }) [(fun:kvs $sz)] |
      fun:butlast |
      fun:listify |
      base:prepend (all) $div |
      base:append (all) ' ' $div |
      explode (all) |
      joins '' |
      echo (all)
  } $ms

  # footer
  put (chr 0x2570) (repeat (- $width 2) (chr 0x2500)) (chr 0x256f) | joins '' | echo (all)
}

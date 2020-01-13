use re
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

fn is-decimal-string [x]{
  or (re:match "^[0-9]+$" $x) \
     (re:match "^[0-9]+[.][0-9]+$" $x)
}

fn rep [x &padding=0 &eval=$false]{
  if (base:is-string $x) {
    if (is-decimal-string $x) {
      rune:lpad $padding $x
    } else {
      rune:rpad $padding $x
    }
  } elif (base:is-number $x) {
     to-string $x | rune:lpad $padding (all)
  } elif (base:is-fn $x) {
    if $eval {
      put '()=>' (rep ($x) &padding=0 &eval=$true) |
        joins ' ' | rune:lpad $padding (all)
    } else {
      rune:lpad $padding fn
    }
  } elif (base:is-bool $x) {
    if $x {
      rune:lpad $padding t
    } else {
      rune:lpad $padding f
    }
  } elif (base:is-list $x) {
    put '[' (count $x) ' items]' | 
      joins '' |
      rune:lpad $padding (all)
  } elif (base:is-map $x) {
    put '[& ' (count $x) ' items]' | 
      joins '' |
      rune:lpad $padding (all)
  }
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

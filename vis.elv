use str
use re
use ./fun

fn truncatef64 [n]{
  n @_ = (to-string $n | re:split '\.' (all))
  put (float64 $n)
}

fn floor [n]{
  if (< $n 0) {
    truncatef64 (fun:dec $n)
  } else {
    truncatef64 $n
  }
}

fn ceil [n]{
  if (< $n 0) {
    truncatef64 $n
  } else {
    fun:inc (truncatef64 $n)
  }
}

fn truncatestr [n s]{
  put $s[:(fun:min $n (count $s))]
}

fn lpad [n s &char="."]{
  l = (- $n (count $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $pad $s | joins ''
  } else {
    put $s
  }
}

fn rpad [n s &char="."]{
  l = (- $n (count $s))
  if (> $l 0) {
    pad = (repeat $l $char | joins '')
    put $s $pad | joins ''
  } else {
    put $s
  }
}

fn sparky [@args &min=$false &max=$false]{
  @args = (fun:check-pipe $args)
  ref = [▁ ▂ ▃ ▄ ▅ ▆ ▇ █]

  min = (or $min (fun:min $@args))
  max = (or $max (fun:max $@args))
  sz = (/ (- $max $min) (fun:dec (count $ref)))
  
  @sparks = (each [a]{
    if (< $a $min) {
      put ' '
    } elif (> $a $max) {
      put █
    } else {
      idx = (truncatef64 (/ (- $a $min) $sz))
      put $ref[$idx]
    }
  } $args)

  joins '' $sparks
}

fn barky [m &formatter=$lpad~
          &pad-char=" " &bar-char=█ 
          &max-cols=80 &desc-pct=.125 
          &min=$false &max=$false]{

  if (not (< 0 $desc-pct 1)) {
    put "invalid description size"
    return
  }

  # - 4 takes into account implicit quotes, and the '> ' 'prompt'
  cols = (fun:min $max-cols (- (float64 (tput cols)) 4))
  desc-room = (* $desc-pct $cols | 
      fun:dec (all) |
      truncatef64 (all) |
      fun:max 1 (all))

  @kvs = (fun:kvs $m)

  m2 = (fun:reduce [a b]{
    a = (assoc $a min (fun:min $a[min] $b[1]))
    a = (assoc $a max (fun:max $a[max] $b[1]))
    k = (truncatestr $desc-room $b[0] | 
        $formatter $desc-room (all) &char=$pad-char)
    a = (fun:assoc-in $a [m $k] (truncatef64 $b[1]))
    put $a
  } [&min=0 &max=0 &m=[&]] $@kvs)

  min = (or $min $m2[min])
  max = (or $max $m2[max])
  @kvs = (fun:kvs $m2[m])
  bar-room = (- $cols $desc-room 1)
  unitsz = (/ $bar-room (- $max $min))

  each (fun:destruct [k v]{
    if (< $v $min) {
      put $k
    } elif (> $v $max) {
      bar = (repeat $bar-room $bar-char | joins '')
      put $k $bar | joins ' '
    } else {
      n = (truncatef64 (* (- $v $min 1) $unitsz))
      bar = (repeat $n $bar-char | joins '')
      put $k $bar | joins ' '
    }
  }) $kvs
}

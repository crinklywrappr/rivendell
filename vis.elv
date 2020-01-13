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
          &max-cols=80 &desc-pct=.125 
          &min=$false &max=$false]{

  if (not (< 0 $desc-pct 1)) {
    put "invalid description size"
    return
  }

  # - 4 takes into account implicit quotes, and the '> ' 'prompt'
  cols = (fun:min $max-cols (- (float64 (tput cols)) 4))
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
      put $k
    } elif (> $v $max) {
      bar = (repeat $bar-room $bar-char | joins '')
      put $k $bar | joins ' '
    } else {
      n = (num:truncatef64 (* (- $v $min 1) $unitsz))
      bar = (repeat $n $bar-char | joins '')
      put $k $bar | joins ' '
    }
  }) $kvs
}

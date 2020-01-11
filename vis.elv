use str
use ./fun

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
      idx = (to-string (/ (- $a $min) $sz))
      float = (str:last-index $idx .)
      if (> $float -1) {
        idx = $idx[:$float]
      }
      put $ref[$idx]
    }
  } $args)

  joins '' $sparks
}

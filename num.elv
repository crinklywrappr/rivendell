use re
use ./base

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

fn abs [n]{
  if (base:neg $n) {
    put (* $n -1)
  } else {
    put $n
  }
}

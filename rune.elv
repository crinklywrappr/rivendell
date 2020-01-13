use ./fun

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

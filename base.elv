use re

fn is-zero [n]{ == 0 $n }
fn is-one [n]{ == 1 $n }
fn is-even [n]{ == (% $n 2) 0 }
fn is-odd [n]{ == (% $n 2) 1 }
fn dec [n]{ - $n 1 }
fn inc [n]{ + $n 1 }
fn pos [n]{ > $n 0 }
fn neg [n]{ < $n 0 }

fn is-fn [x]{ eq (kind-of $x) fn }
fn is-map [x]{ eq (kind-of $x) map }
fn is-list [x]{ eq (kind-of $x) list }
fn is-string [x]{ eq (kind-of $x) string }
fn is-bool [x]{ eq (kind-of $x) bool }
fn is-number [x]{ eq (kind-of $x) !!float64 }
fn is-nil [x]{ eq $x $nil }

fn splice-from [coll from empty]{
  l = (count $coll)
  if (> $from $l) {
    put $empty
  } else {
    put $coll[{$from}:]
  }
}

fn splice-to [coll to]{
  l = (count $coll)
  if (> $to $l) {
    put $coll
  } else {
    put $coll[:$to]
  }
}

fn prepend [li @args]{ put [(put $@args (explode $li))] }
fn append  [li @args]{ put [(put (explode $li) $@args)] }
fn concat2 [l1 l2]{ put [(explode $l1) (explode $l2)] }
fn pluck [li n]{ put [(explode $li[:$n]) (explode $li[(inc $n):])] }
fn get [li n]{ put $li[$n] } 
fn first [li]{ put $li[0] }
fn ffirst [li]{ first (first $li) }
fn second [li]{ put $li[1] }
fn rest [li]{ put $li[1:] }
fn end [li]{ put $li[-1] }
fn butlast [li]{ put $li[:(dec (count $li))] }

fn min2 [a b]{
  if (< $a $b) {
    put $a
  } else {
    put $b
  }
}

fn max2 [a b]{
  if (> $a $b) {
    put $a
  } else {
    put $b
  }
}

fn nth [li n &not-found=$false]{
  if (and $not-found (> $n (count $li))) {
    put $not-found
  } else {
    drop $n $li | take 1
  }
}

fn is-empty [li]{ is-zero (count $li) }
fn check-pipe [li]{
  # use when taking @args
  if (is-empty $li) {
    put (all)
  } else {
    explode $li
  }
}

fn flatten [li]{
  if (eq (kind-of $li) list) {
    f = placeholder
    f = [x]{
      if (eq (kind-of $x) list) {
        each $f $x
      } else {
        put $x
      }
    }
    each $f $li
  }
}

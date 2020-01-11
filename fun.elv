fn is-zero [n]{ == 0 $n }
fn is-one [n]{ == 1 $n }
fn is-even [n]{ == (% $n 2) 0 }
fn is-odd [n]{ == (% $n 2) 1 }
fn dec [n]{ - $n 1 }
fn inc [n]{ + $n 1 }
fn pos [n]{ > $n 0 }
fn neg [n]{ < $n 0 }

fn abs [n]{
  if (neg $n) {
    put (* $n -1)
  } else {
    put $n
  }
}

fn is-map [x]{ eq (kind-of $x) map }
fn is-list [x]{ eq (kind-of $x) list }
fn is-string [x]{ eq (kind-of $x) string }
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
fn swap [coll x y]{ assoc (assoc $coll $x $coll[$y]) $y $coll[$x] }
fn update [coll k f @args]{ assoc $coll $k ($f $coll[$k] $@args) }

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

fn listify [@els]{ 
  @els = (check-pipe $els)
  put $els 
}
fn destruct [f]{
  put [x]{
    $f (explode $x)
  }
}

fn complement [f]{ put [x]{ not ($f $x) } }

fn partial [f @supplied]{
  put [@args]{ 
    @args = (check-pipe $args)
    $f $@supplied $@args 
  }
}

fn juxt [@fns]{
  put [@args]{
    @args = (check-pipe $args)
    for f $fns {
      $f $@args
    }
  }
}

fn reduce [f acc @arr]{
  for a $arr {
    acc = ($f $acc $a)
  }
  put $acc
}

fn filter [f @arr]{
  each [a]{
    if ($f $a) {
      put $a
    }
  } $arr
}

fn pfilter [f @arr]{
  peach [a]{
    if ($f $a) {
      put $a
    }
  } $arr
}

fn remove [f @arr]{
  filter (complement $f) $@arr
}

fn premove [f @arr]{
  pfilter (complement $f) $@arr
}

fn flatten [li]{
  if (eq (kind-of $li) list) {
    f = placehoder
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

fn kvs [map]{
  ## This makes maps iterable
  each [k]{
    put [$k $map[$k]]
  } [(keys $map)]
}

fn into [container @arr]{
  if (eq (kind-of $container) map) {
    reduce [a b]{
      k @v = (explode $b)
      if (is-one (count $v)) {
        v = $v[0]
      }
      assoc $a $k $v
    } $container $@arr
  } elif (eq (kind-of $container) list) {
    concat2 $container $arr
  }
}

fn reverse [@arr]{
  @arr = (check-pipe $arr)
  i lim = 1 (inc (count $arr))
  while (< $i $lim) {
    put $arr[-$i]
    i = (inc $i)
  }
}

fn comp [@fns]{
  put [@x]{
    @x = (check-pipe $x)
    for f [(reverse $@fns)] {
      @x = ($f (explode $x))
    }
    put (explode $x)
  }
}

fn box [f]{
  comp $listify~ $f
}

fn distinct [@args]{
  @args = (check-pipe $args)
  into [&] $@args | keys (all)
}

fn unique [@args &count=$false]{
  a @args = (check-pipe $args)
  if $count {
    i = 1
    for x $args {
      if (!=s $x $a) {
        put [$i $a]
	a = $x
	i = 1
      } else {
        i = (inc $i)
      }
    }
    put [$i (end $args)]
  } else {
    for x $args {
      if (!=s $x $a) {
        put $a
	a = $x
      }
    }
    put (end $args)
  }
}

fn merge [@maps]{
  @maps = (check-pipe $maps)
  reduce [a b]{
    into $a (kvs $b)
  } [&] $@maps
}

fn merge-with [f @maps]{
  reduce [a b]{
    reduce [a b]{
      try {
        _ = $a[$b[0]]
      } except e {
        assoc $a $b[0] $b[1]
      } else {
        update $a $b[0] $f $b[1]
      }
    } $a (kvs $b)
  } [&] $@maps
}

fn concat [@lists]{
  @lists = (check-pipe $lists)
  reduce [a b]{
    concat2 $a $b
  } [] $@lists
}

fn min [@arr]{
  a @arr = (check-pipe $arr)
  reduce [a b]{
    if (< $b $a) {
      put $b
    } else {
      put $a
    }
  } $a $@arr
}

fn min-key [f @arr]{
  a @arr = $@arr

  v = (reduce [a b]{
    fb = ($f $b)
    if (< $fb $a[1]) {
      put [$b $fb]
    } else {
      put $a
    }
  } [$a ($f $a)] $@arr)

  put $v[0]
}

fn max [@arr]{
  a @arr = (check-pipe $arr)
  reduce [a b]{
    if (> $b $a) {
      put $b
    } else {
      put $a
    }
  } $a $@arr
}

fn max-key [f @arr]{
  a @arr = $@arr

  v = (reduce [a b]{
    fb = ($f $b)
    if (> $fb $a[1]) {
      put [$b $fb]
    } else {
      put $a
    }
  } [$a ($f $a)] $@arr)

  put $v[0]
}

fn some [f @args]{
  res = $false
  for a $args {
    res = ($f $a)
    if $res {
      break
    }
  }
  put $res
}

fn not-every [f @args]{
  some (complement $f) $@args
}

fn every [f @args]{
  not (not-every $f $@args)
}

fn not-any [f @args]{
  not (some $f $@args)
}

fn first-pred [f @args]{
  res = $false
  for a $args {
    res = ($f $a)
    if $res {
      put $a
      break
    }
  }
}

fn map [f @args]{
  if (every [a]{ eq (kind-of $a) list } $@args) {
    shortest = (each $count~ $args | min)
    each [i]{
      each [l]{
        put $l[$i]
      } $args | $f (all)
    } [(range $shortest)]
  } else {
    each $f $args
  }
}

fn pmap [f @args]{
  if (every [a]{ eq (kind-of $a) list } $@args) {
    shortest = (each $count~ $args | min)
    peach [i]{
      each [l]{
        put $l[$i]
      } $args | $f (all)
    } [(range $shortest)]
  } else {
    peach $f $args
  }
}

fn map-indexed [f @args]{
  if (every [a]{ eq (kind-of $a) list } $@args) {
    shortest = (each $count~ $args | min)
    put [(range $shortest)] $@args | map $f (all)
  } else {
    put [(range (count $args))] $args | map $f (all) 
  }
}

fn interleave [@lists]{
  @lists = (check-pipe $lists)
  map $put~ $@lists
}

fn interpose [sep @args]{
  interleave $args [(repeat (count $args) $sep)]
}

fn partition [n @args &step=$false &pad=$false]{
  if (and (> $n 0) (or (not $step) (> $step 0))) {
    each [i]{
      li = [(drop $i $args | take $n)]
      if (== $n (count $li)) {
        put $li
      } elif $pad {
        append $li (take (- $n (count $li)) $pad)
      }
    } [(range (count $args) &step=(or $step $n))]
  }
}

fn partition-all [n @args]{
  partition $n $@args &pad=[]
}

fn difference [l1 l2]{
  into [&] (explode $l1) |
    reduce [a b]{
      dissoc $a $b
    } (all) (explode $l2) |
    keys (all)
}

fn union [@lists]{
  @lists = (check-pipe $lists)
  concat $@lists | explode (all) | distinct
}

fn iterate [f n seed]{
  i = 1
  put $seed
  while (< $i $n) {
    seed = ($f $seed)
    i = (inc $i)
    put $seed
  }
}

fn rand-sample [n @args]{
  for x $args {
    if (<= (rand) $n) {
      put $x
    }
  }
}

fn sample [n @args]{
  rand-idx = (comp (partial $randint~ 0) $count~ $second~)
  f = (comp $listify~ (juxt $get~ $pluck~) (juxt $second~ $rand-idx))
  iterate $f (inc $n) ['' $args] | drop 1 | each $first~
}

fn shuffle [@args]{
  @args = (check-pipe $args)
  sample (count $args) $@args
}

fn frequencies [@args]{
  unique &count=$true $@args |
    each (destruct [v k]{ put [&$k=$v] }) |
    merge-with $+~ (all)
}

fn group-by [f @args]{
  mapfn = (comp (partial $into~ [&]) $listify~ (juxt $f (box $put~)))
  each $mapfn $args | merge-with $concat~ (all)
}

fn intersection [@lists]{
  @lists = (check-pipe $lists)

  c = (count $lists)
  f = (destruct [k v]{ == (count $v) $c })

  each (destruct $distinct~) $lists |
    group-by $put~ (all) |
    kvs (all) | 
    filter $f (all) | 
    each $first~
}

fn zipmap [ks vs]{
  interleave $ks $vs | partition 2 (all) | into [&] (all)
}

fn in [val possibilities]{
  # doesn't accomodate numbers
  some (partial $eq~ $val) (explode $possibilities)
}

fn contains [coll k]{
  if (in (kind-of $coll) [list string]) {
    < $k (count $coll)
  } elif (eq (kind-of $coll) map) {
    has-key $coll $k
  }
}

fn find [m k]{
  if (contains $m $k) {
    put [$k $m[$k]]
  }
}

fn select-keys [m @ks]{
  each (partial $find~ $m) $ks | (partial $into~ [&])
}

fn get-in [m @ks]{
  if (> (count $ks) 1) {
    get-in $m[$ks[0]] (drop 1 $ks)
  } else {
    put $m[$ks[0]]
  }
}

fn assoc-in [m ks v]{
  if (> (count $ks) 1) {
    assoc $m $ks[0] (assoc-in $m[$ks[0]] (rest $ks) $v)
  } else {
    assoc $m $ks[0] $v
  }
}

fn update-in [m ks f @args]{
  if (> (count $ks) 1) {
    assoc $m $ks[0] (update-in $m[$ks[0]] (rest $ks) $f $@args)
  } else {
    update $m $ks[0] $f $@args
  }
}

fn index [maps @ks]{
  group-by [m]{ select-keys $m $@ks } (explode $maps)
}

fn reduce-kv [f acc m]{
  for kv [(kvs $m)] {
    acc = ($f $acc $kv[0] $kv[1])
  }
  put $acc
}

fn take-nth [n @args]{
  partition 1 &step=$n $@args | each $explode~
}

fn take-while [f @args]{
  for x $args {
    if ($f $x) {
      put $x
    } else {
      break
    }
  }
}

fn drop-while [f @args]{
  i = 0
  c = (count $args)
  while (and (< $i $c) ($f $args[$i])) {
    i = (inc $i)
  }
  put (explode $args[(put $i):])
}

fn map-invert [m]{
  kvs $m | each (box (destruct $reverse~)) | (partial $into~ [&])
}

fn rename-keys [m km]{
  kvs $m |
    each (destruct [k v]{
      if (contains $km $k) {
        put [$km[$k] $v]
      } else {
        put [$k $v]
      }
    }) | (partial $into~ [&])
}

fn drop-last [n @args]{
  take (- (count $args) $n) $args
}

fn butlast [@args]{
  drop-last 1 $@args
}

fn memoize [f]{
  cache = [&]
  put [@args]{
    if (contains $cache $args) {
      explode $cache[$args]
    } else {
      @res = ($f $@args)
      cache = (assoc $cache $args $res)
      put $@res
    }
  }
}

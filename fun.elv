use ./base

fn swap [coll x y]{
  assoc (assoc $coll $x $coll[$y]) $y $coll[$x]
}

fn update [coll k f @args]{ 
  assoc $coll $k ($f $coll[$k] $@args) 
}

fn listify [@els]{ 
  @els = (base:check-pipe $els)
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
    @args = (base:check-pipe $args)
    $f $@supplied $@args 
  }
}

fn juxt [@fns]{
  put [@args]{
    @args = (base:check-pipe $args)
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

fn vals [map]{
  ## Hard to believe this isn't a builtin
  each [k]{
    put $map[$k]
  } [(keys $map)]
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
      if (base:is-one (count $v)) {
        v = $v[0]
      }
      assoc $a $k $v
    } $container $@arr
  } elif (eq (kind-of $container) list) {
    base:concat2 $container $arr
  }
}

fn reverse [@arr]{
  @arr = (base:check-pipe $arr)
  i lim = 1 (base:inc (count $arr))
  while (< $i $lim) {
    put $arr[-$i]
    i = (base:inc $i)
  }
}

fn comp [@fns]{
  put [@x]{
    @x = (base:check-pipe $x)
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
  @args = (base:check-pipe $args)
  into [&] $@args | keys (all)
}

fn unique [@args &count=$false]{
  a @args = (base:check-pipe $args)
  if $count {
    i = 1
    for x $args {
      if (!=s $x $a) {
        put [$i $a]
	a = $x
	i = 1
      } else {
        i = (base:inc $i)
      }
    }
    put [$i (base:end $args)]
  } else {
    for x $args {
      if (!=s $x $a) {
        put $a
	a = $x
      }
    }
    put (base:end $args)
  }
}

fn merge [@maps]{
  @maps = (base:check-pipe $maps)
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
  @lists = (base:check-pipe $lists)
  reduce [a b]{
    base:concat2 $a $b
  } [] $@lists
}

fn min [@arr]{
  a @arr = (base:check-pipe $arr)
  reduce [a b]{
    base:min2 $a $b
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
  a @arr = (base:check-pipe $arr)
  reduce [a b]{
    base:max2 $a $b
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

fn mapcat [f @args]{
  map $f $@args | concat
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
  @lists = (base:check-pipe $lists)
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
        base:append $li (take (- $n (count $li)) $pad)
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
  @lists = (base:check-pipe $lists)
  concat $@lists | explode (all) | distinct
}

fn iterate [f n seed]{
  i = 1
  put $seed
  while (< $i $n) {
    seed = ($f $seed)
    i = (base:inc $i)
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
  rand-idx = (comp (partial $randint~ 0) $count~ $base:second~)
  f = (comp $listify~ (juxt $base:get~ $base:pluck~) (juxt $base:second~ $rand-idx))
  iterate $f (base:inc $n) ['' $args] | drop 1 | each $base:first~
}

fn shuffle [@args]{
  @args = (base:check-pipe $args)
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
  @lists = (base:check-pipe $lists)

  c = (count $lists)
  f = (destruct [k v]{ == (count $v) $c })

  each (destruct $distinct~) $lists |
    group-by $put~ (all) |
    kvs (all) | 
    filter $f (all) | 
    each $base:first~
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
    assoc $m $ks[0] (assoc-in $m[$ks[0]] (base:rest $ks) $v)
  } else {
    assoc $m $ks[0] $v
  }
}

fn update-in [m ks f @args]{
  if (> (count $ks) 1) {
    assoc $m $ks[0] (update-in $m[$ks[0]] (base:rest $ks) $f $@args)
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
    i = (base:inc $i)
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
  @args = (base:check-pipe $args)
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

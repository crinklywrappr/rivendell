use ./fun

fn iterator [f &meta=$false &seed=[$false]]{
  record = $false
  tape = []

  next = (if $meta {
      put []{
        if (not (eq $seed [])) {
	  if (and (not (eq $seed [$false])) $record) {
	    tape = (fun:append $tape $@seed)
	  }
          @resp = ($f $meta $@seed)
	  if (> (count $resp) 1) {
	    meta = (take 1 $resp)
	    @seed = (drop 1 $resp)
	  } else {
	    seed = []
	  }
        }
      }
    } else {
      put []{
        if (not (eq $seed [])) {
	  if (and (not (eq $seed [$false])) $record) {
	    tape = (fun:append $tape $@seed)
	  }
	  @seed = ($f $@seed)
	}
      }
    })
  
  need-seed = (eq $seed [$false])
  
  curr = (if $need-seed {
      put []{
        if $need-seed {
          nop ($next)
	  need-seed = $false
        }
        put $@seed
      }
    } else {
      put []{
        put $@seed
      }
    })

  put [
    &playback=[]{
      put $@tape
    }
    &curr=$curr
    &next=$next
    &exhausted=[]{
      eq $seed []
    }
    &record=[tf]{
      record = (bool $tf)
    }]
}

# basic iterators

fn iter-seq [@args]{
  @args = (fun:check-pipe $args)
  c = (fun:dec (count $args))
  iterator [meta @seed]{
    if (< $meta $c) {
      put (fun:inc $meta)
      put $args[(fun:inc $meta)]
    }
  } &seed=$args[0] &meta=0
}

fn cycle [@args]{
  @args = (fun:check-pipe $args)
  c = (fun:dec (count $args))
  iterator [meta @seed]{
    if (== $meta $c) {
      put 0 $args[0]
    } else {
      put (fun:inc $meta)
      put $args[(fun:inc $meta)]
    }
  } &seed=[$args[0]] &meta=0
}

fn iterate [f @seed]{
  iterator &seed=$seed [@seed]{
    $f $@seed
  }
}

# high level iterators

fn filter [f iter]{
  iterator [@_]{
    while (and (not ($iter[exhausted])) (not ($f ($iter[curr])))) {
      nop ($iter[next])
    }
    if (not ($iter[exhausted])) {
      put ($iter[curr])
      nop ($iter[next])
    }
  }
}

fn remove [f iter]{
  filter (fun:complement $f) $iter
}

fn unique [iter &count=$false]{
  if $count {
    iterator [@_]{
      if (not ($iter[exhausted])) {
        c x = 0 ($iter[curr])
        while (and (not ($iter[exhausted])) (eq $x ($iter[curr]))) {
	  c = (fun:inc $c)
          nop ($iter[next])
        }
        put [$c $x]
      }
    }
  } else {
    iterator [@_]{
      if (not ($iter[exhausted])) {
        x = ($iter[curr])
        while (and (not ($iter[exhausted])) (eq $x ($iter[curr]))) {
          nop ($iter[next])
        }
        put $x
      }
    }
  }
}

fn map [f @iters]{
  if (> (count $iters) 1) {
    iterator [@_]{
      over = (fun:some [i]{ put ($i[exhausted]) } $@iters)
      if (not $over) {
	put (each [i]{ $i[curr] } $iters | $f (all))
	nop (each [i]{ $i[next] } $iters)
      }
    }
  } else {
    iterator &meta=$iters[0] [meta @_]{
      if (not ($meta[exhausted])) {
        put $meta ($f ($meta[curr]))
	nop ($meta[next])
      }
    }
  }
}

fn map-indexed [f @iters]{
  idx-iter = (iterator &seed=0 $fun:inc~)
  iters = (fun:prepend $iters $idx-iter)
  map $f (explode $iters)
}

fn interleave [@iters]{
  map $put~ $@iters
}

fn interpose [sep iter]{
  interleave $iter (cycle $sep)
}

fn ltake [n iter]{
  iterator &meta=0 [meta @_]{
    if (and (not ($iter[exhausted])) (< $meta $n)) {
      put (fun:inc $meta) ($iter[curr])
      nop ($iter[next])
    }
  }
}

fn ldrop [n iter]{
  iterator &meta=0 [meta @_]{
    while (and (not ($iter[exhausted])) (< $meta $n)) {
      nop ($iter[next])
      meta = (fun:inc $meta)
    }
    if (not ($iter[exhausted])) {
      put $n ($iter[curr])
      nop ($iter[next])
    }
  }
}

fn rest [iter]{
  ldrop 1 $iter
}

fn take-while [f iter]{
  iterator &meta=$true [meta @_]{
    if (and $meta (not ($iter[exhausted]))) {
      meta = ($f ($iter[curr]))
      if $meta {
        put $meta ($iter[curr])
	nop ($iter[next])
      }
    }
  }
}

fn drop-while [f iter]{
  iterator &meta=$true [meta @_]{
    if $meta {
      while (and (not ($iter[exhausted])) ($f ($iter[curr]))) {
        nop ($iter[next])
      }
    }
    if (not ($iter[exhausted])) {
      put $false ($iter[curr])
      nop ($iter[next])
    }
  }
}

fn partition [n iter &step=$false &pad=$false]{
  if (and (> $n 0) (or (not $step) (> $step 0))) {
    if (and $step (< $step $n)) {
      iterator [@seed]{
        if (eq $seed [$false]) {
	  seed = []
	}
	@bb = (drop $step $@seed)
	i = (count $bb)
	@els = (while (and (not ($iter[exhausted])) (< $i $n)) {
	  i = (fun:inc $i)
	  put ($iter[curr])
	  nop ($iter[next])
	})
	els = [$@bb $@els]
	c = (count $els)
	if (> $c 0) {
	  if (== $c $n) {
	    put $els
	  } elif $pad {
	    put (fun:append $els (take (- $n $c) $pad))
	  }
	}
      }
    } elif (and $step (> $step $n)) {
      iterator [@_]{
        i = 0
	@els = (while (and (not ($iter[exhausted])) (< $i $n)) {
	  i = (fun:inc $i)
	  put ($iter[curr])
	  nop ($iter[next])
	})
	c = (count $els)
	if (> $c 0) {
	  if (== $c $n) {
	    put $els
	    while (and (not ($iter[exhausted])) (< $i $step)) {
	      i = (fun:inc $i)
	      nop ($iter[next])
	    }
	  } elif $pad {
	    put (fun:append $els (take (- $n $c) $pad))
	  }
	}
      }
    } else {
      iterator [@_]{
        i = 0
	@els = (while (and (not ($iter[exhausted])) (< $i $n)) {
	  i = (fun:inc $i)
	  put ($iter[curr])
	  nop ($iter[next])
	})
	c = (count $els)
	if (> $c 0) {
	  if (== $c $n) {
	    put $els
	  } elif $pad {
	    put (fun:append $els (take (- $n $c) $pad))
	  }
	}
      }
    }
  }
}

fn partition-all [n iter]{
  partition $n $iter &pad=[]
}

fn take-nth [n iter]{
  partition 1 &step=$n $iter | map $explode~ (all)
}

# consumers

fn blast [iter]{
  while (not ($iter[exhausted])) {
    put ($iter[curr])
    nop ($iter[next])
  }
}

fn first [iter]{
  put ($iter[curr])
}

fn nth [n iter]{
  ldrop (fun:dec $n) $iter | (fun:partial $ltake~ 1) | blast (all)
}

fn some [f iter]{
  res = $false
  while (not ($iter[exhausted])) {
    res = ($f ($iter[curr]))
    if $res {
      break
    }
    nop ($iter[next])
  }
  put $res
}

fn not-every [f iter]{
  some (fun:complement $f) iter
}

fn every [f iter]{
  not (not-every $f iter)
}

fn not-any [f iter]{
  not (some $f iter)
}

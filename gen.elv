use ./fun
use ./lazy

fn fibs []{
  f = (fun:box (fun:destruct [x y]{
      put $y (+ $x $y)
    }))
  lazy:iterate $f [1 1] |
    (fun:partial $lazy:map~ $fun:first~)
}

fn primes []{

  enqueue = (put [sieve n step]{
    k = (+ $n $step)
    while (has-key $sieve $k) {
      k = (+ $k $step)
    }
    assoc $sieve $k $step
  })

  next-sieve = (put [sieve k]{
    if (has-key $sieve $k) {
      step = $sieve[$k]
      sieve = (dissoc $sieve $k)
      $enqueue $sieve $k $step
    } else {
      $enqueue $sieve $k (+ $k $k)
    }
  })

  next-primes = (put [sieve @seed]{
    k = $@seed
    sieve = ($next-sieve $sieve $k)
    k = (+ $k 2)
    while (has-key $sieve $k) {
      sieve = ($next-sieve $sieve $k)
      k = (+ $k 2)
    }
    put $sieve $k
  })

  lazy:iterator $next-primes &meta=[&] &seed=[(float64 3)] |
    lazy:prepend (all) (float64 2)
}

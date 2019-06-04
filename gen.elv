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
  update-map = [m curr]{
      for k [(keys $m)] {
        if (>= $curr $m[$k]) {
          m = (fun:update $m $k $+~ $k $k)
        }
      }
      put $m
    }
  lazy:iterator [meta @seed]{
    i = $@seed
    looking = $true
    while $looking {
      i = (+ $i 2)
      if (not (fun:some [k]{ == $meta[$k] $i } (keys $meta))) {
        meta = (assoc $meta $i (* $i 3))
	looking = $false
      }
      meta = ($update-map $meta $i)
    }
    put $meta $i
  } &meta=[&3=9] &seed=3
}

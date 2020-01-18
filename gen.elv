use ./base
use ./fun
use ./lazy
use ./test

fn fibs []{
  f = (fun:box (fun:destruct [x y]{
      put $y (+ $x $y)
    }))
  lazy:iterate $f [(float64 1) (float64 1)] |
    (fun:partial $lazy:map~ $base:first~)
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

tests = [
  ["first 100 primes"
  (test:matches (each $float64~ [2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 257 263 269 271 277 281 283 293 307 311 313 317 331 337 347 349 353 359 367 373 379 383 389 397 401 409 419 421 431 433 439 443 449 457 461 463 467 479 487 491 499 503 509 521 523 541] | fun:listify))
  []{ primes | lazy:ltake 100 (all) | lazy:blast (all) | fun:listify }]

  ["first 30 fibonacci numbers"
  (test:matches (each $float64~ [1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946 17711 28657 46368 75025 121393 196418 317811 514229 832040] | fun:listify))
  []{ fibs | lazy:ltake 30 (all) | lazy:blast (all) | fun:listify }]
]

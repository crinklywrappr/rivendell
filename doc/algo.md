# algo.elv
1. [testing-status](#testing-status)
2. [fibs](#fibs)
3. [primes](#primes)
4. [levenshtein](#levenshtein)
***
## testing-status
4 tests passed out of 4

100% of tests are passing

 
Miscelaneous algorithms and generators to showcase rivendell.  May not be useful.
***
## fibs
 
This is a var that represents an infinite list of fibonacci numbers.
```elvish
l:take 10 $fibs | l:blast
▶ 1
▶ 1
▶ 2
▶ 3
▶ 5
▶ 8
▶ 13
▶ 21
▶ 34
▶ 55
```
***
## primes
 
Function which returns an iterator which represents an infinite list of primes.
```elvish
l:take 10 (primes) | l:blast
▶ 2
▶ 3
▶ 5
▶ 7
▶ 11
▶ 13
▶ 17
▶ 19
▶ 23
▶ 29
```
***
## levenshtein
 
basic levenshtein function to measure the distance between two strings.
```elvish
levenshtein hello hello
▶ 0
```
```elvish
levenshtein hello world
▶ 4
```

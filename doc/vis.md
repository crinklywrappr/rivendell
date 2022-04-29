# vis.elv
1. [testing-status](#testing-status)
2. [sparky](#sparky)
3. [barky](#barky)
***
## testing-status
8 tests passed out of 8

100% of tests are passing

 
Hosts functions to help with visualization
***
## sparky
 
Produces a sparkline from input
 
increasing sparkline
```elvish
range 20 | sparky
▶  ▁▁▂▂▂▃▃▃▄▄▅▅▅▆▆▆▇▇█
```
 
decreasing sparkline
```elvish
range 20 | f:reverse | sparky
▶ █▇▇▆▆▆▅▅▅▄▄▃▃▃▂▂▂▁▁ 
```
 
min=max sparkline
```elvish
range 20 | sparky &max=0
repeat 20 0 | sparky
```
```elvish
▶                    
```
 
mostly max sparkline
```elvish
range 20 | sparky &max=1
▶  ███████████████████
```
 
window sparkline
```elvish
range 20 | sparky &min=5 &max=15
▶       ▁▂▃▃▄▅▅▆▇█████
```
 
shuffled sparkline
```elvish
range 20 | f:shuffle | sparky
▶ ▂▆▄▃▅▂▃▇▂▄▅▆▅▆▁ ▃▇▁█
```
***
## barky
 
Produces histograms.  Has lots of options.
 
Charting the first 11 prime numbers.
```elvish
   use ./algo
   use ./lazy
   algo:primes ^
     | lazy:map-indexed {|k v| put [{$k}={$v} $v]} ^
       | lazy:take 11 ^
         | lazy:blast ^
           | barky (all) &desc-pct=(num 0.1) &min=(num 0)
           
▶     0=2 ██
▶     1=3 ████
▶     2=5 █████████
▶     3=7 █████████████
▶    4=11 ███████████████████████
▶    5=13 ███████████████████████████
▶    6=17 █████████████████████████████████████
▶    7=19 █████████████████████████████████████████
▶    8=23 ███████████████████████████████████████████████████
▶    9=29 █████████████████████████████████████████████████████████████████
▶   10=31 █████████████████████████████████████████████████████████████████████
```

# rune.elv
1. [testing-status](#testing-status)
2. [is-unicode/is-ascii](#is-unicode/is-ascii)
3. [substr](#substr)
4. [trunc](#trunc)
5. [lpad/rpad](#lpad/rpad)
6. [center](#center)
***
## testing-status
28 tests passed out of 28

100% of tests are passing

 
Hosts functions which operate on text.  Tries to behave sanely with variable-width characters.
***
## is-unicode/is-ascii
 
predicates which tell you whether or not the string uses wide characters.
```elvish
is-ascii hello
is-unicode '你好，世界'
```
```elvish
▶ $true
```
```elvish
is-unicode hello
is-ascii '你好，世界'
```
```elvish
▶ $false
```
***
## substr
 
produces a substring.
 
returns the string with no options.
```elvish
substr hello
▶ hello
```
```elvish
substr '你好，世界'
▶ 你好，世界
```
 
starts at 0 when `from` is not provided
```elvish
substr hello &to=2
▶ he
```
```elvish
substr '你好，世界' &to=2
▶ 你好
```
 
goes to the end of the string when `to` is not provided.
```elvish
substr hello &from=1
▶ ello
```
```elvish
substr '你好，世界' &from=1
▶ 好，世界
```
 
feel free to mix them.
```elvish
substr hello &from=1 &to=3
▶ el
```
```elvish
substr '你好，世界' &from=1 &to=3
▶ 好，
```
 
negative indices can be provided.
```elvish
substr hello &from=-4
▶ ello
```
```elvish
substr '你好，世界' &from=-4
▶ 好，世界
```
 
positive and negative indices can be mixed.
```elvish
substr hello &from=1 &to=-1
▶ ell
```
```elvish
substr '你好，世界' &from=1 &to=-1
▶ 好，世
```
***
## trunc
 
truncates a string to a specified screen width.
```elvish
trunc 9 'hello, world'
▶ hello, w…
```
```elvish
trunc 9 '你好，世界'
▶ 你好，世…
```
 
a sufficient width will return the whole string.
```elvish
trunc 12 'hello, world'
▶ hello, world
```
```elvish
trunc 10 '你好，世界'
▶ 你好，世界
```
 
a width too small will just return the elipsis.
```elvish
trunc 1 'hello, world'
trunc 2 '你好，世界'
```
```elvish
▶ …
```
***
## lpad/rpad
 
Pads a string to width `n`.  By default, the padding char is a space.
 
Only works if the padding char is single-width.
```elvish
rpad 15 hello &char=.
▶ hello..........
```
```elvish
rpad 15 '你好，世界' &char=.
▶ 你好，世界.....
```
```elvish
lpad 15 hello &char=.
▶ ..........hello
```
```elvish
lpad 15 '你好，世界' &char=.
▶ .....你好，世界
```
***
## center
 
Pads a string on both sides, to width `n`.  If the string is odd width, offsets to the left.
 
By default, the padding char is a space.
 
Only works if the padding char is single-width.
```elvish
center 15 '你好，世界' &char=.
▶ ..你好，世界...
```
```elvish
center 15 'world' &char=.
▶ .....world.....
```

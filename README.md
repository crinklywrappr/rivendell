![Rivendell Logo](assets/logo2.png "Rivendell Logo")

## About

This library hosts a number of functions that push [elvish](https://elv.sh/) to it's limits.

- functional bits: high-level functions which encapsulate common design patterns.
- lazy iterators: transducer-inspired iterators which allow you to represent infinite sequences.
- visual aids: sparklines & histograms.
- plus a toolbelt of common utility functions which operate on strings, lists, and maps.

## Documentation

- [test.elv](doc/test.md)
- [base.elv](doc/base.md)
- [fun.elv](doc/fun.md)
- [lazy.elv](doc/lazy.md)
- [rune.elv](doc/rune.md)
- [algo.elv](doc/algo.md)
- [vis.elv](doc/vis.md)

## How to install

It's a 3-step process.

- Add these lines to your `~/.config/elvish/rc.elv`

```elvish
epm:install &silent-if-installed=$true github.com/crinklywrappr/rivendell
epm:upgrade github.com/crinklywrappr/rivendell
```

- Request modules à la carte.

```elvish
use github.com/crinklywrappr/rivendell/test t
use github.com/crinklywrappr/rivendell/base b
use github.com/crinklywrappr/rivendell/fun f
use github.com/crinklywrappr/rivendell/lazy l
use github.com/crinklywrappr/rivendell/rune r
use github.com/crinklywrappr/rivendell/algo a
use github.com/crinklywrappr/rivendell/vis v
```

- Do cool stuff!

```elvish

# lazily graphing population data from the 2021 census

var f = {|line-no| head -n $line-no NST-EST2021-alldata.csv | tail -n 1 | s:split , (one) | f:listify}

var popkeys = ($f 1)

var getpop = {|m| put $m[POPESTIMATE2021]}

var getstate = {|m| put $m[NAME]}

l:nums &start=(num 7) ^
| l:each (f:comp $f (f:partial $f:zipmap~ $popkeys) (f:juxt $getstate $getpop) $f:listify~) ^
| l:take 20 ^
| l:blast ^
| v:barky (all) &min=0

        Alabama ████████
         Alaska █
        Arizona ███████████
       Arkansas ████
     California ███████████████████████████████████████████████████████████████
       Colorado █████████
    Connecticut █████
       Delaware █
District of Co… █
        Florida ███████████████████████████████████
        Georgia █████████████████
         Hawaii ██
          Idaho ███
       Illinois ████████████████████
        Indiana ███████████
           Iowa █████
         Kansas ████
       Kentucky ███████
      Louisiana ███████
          Maine ██
```

## Documentation in the terminal

Command-line users are recommended to use [glow](https://github.com/charmbracelet/glow).

Run the following command to browse the docs.

```shell
glow ~/.local/share/elvish/lib/github.com/crinklywrappr/rivendell/
```

## Testing / Generating documentation
Tests are run and Markdown documentation is generated with this command.

```elvish
use ./gendoc
gendoc:gendoc
```

It places documentation in a `doc` folder relative to your current directory.  Because it is a destructive operation, it is advisable that users should run this in an empty directory.

I recommend [glow](https://github.com/charmbracelet/glow) for reading documentation at the terminal.  It looks sexy.

![documentation illustration](https://user-images.githubusercontent.com/56522/165846897-9fd3a7e6-0fe0-430a-9c95-bb6d98f69e59.png)

## Articles

- [Playing around with Elvish, a new(ish) shell](https://dev.to/crinklywrappr/playing-around-with-elvish-a-new-ish-shell-5h16)
- [Generating docs from tests](https://dev.to/crinklywrappr/generating-docs-from-tests-l64)
- [Flashcards in the terminal](https://dev.to/crinklywrappr/flashcards-in-the-terminal-2akj)

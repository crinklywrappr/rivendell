![Rivendell Logo](assets/logo2.png "Rivendell Logo")

## About

This library hosts a number of functions which push elvish to it's limits.

- functional bits: high-level functions which encapsulate common design patterns
- lazy iterators: transducer-inspired iterators which allow you to represent infinite sequences
- visual aids: sparklines & histograms
- plus a toolbelt of common utility functions which operate on strings, lists, and maps.

## Documentation

- [test.elv](doc/test.md)
- [base.elv](doc/base.md)
- [fun.elv](doc/fun.md)
- [lazy.elv](doc/lazy.md)
- [rune.elv](doc/rune.md)
- [algo.elv](doc/algo.md)
- [vis.elv](doc/vis.md)

Command-line users are recommended to use [glow](https://github.com/charmbracelet/glow).

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

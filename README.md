![Rivendell Logo](assets/logo2.png "Rivendell Logo")

## Documentation

- [test.elv](doc/test.md)

Command-line users are recommended to use `glow`.

## Testing / Generating documentation
Tests are run and Markdown documentation is generated with this command.

```elvish
use ./gendoc
gendoc:gendoc
```

It places documentation in a `doc` folder relative to your current directory.  Because it is a destructive operation, it is advisable that only contributors use this command.


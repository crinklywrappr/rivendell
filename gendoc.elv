use ./test
use ./base
use ./fun
use ./lazy

fn gendoc {
  var err = ?(mkdir doc)

  test:test $test:tests | test:md (all) > doc/test.md
  test:test $base:tests | test:md (all) > doc/base.md
  test:test $fun:tests | test:md (all) > doc/fun.md
  test:test $lazy:tests | test:md (all) > doc/lazy.md
}

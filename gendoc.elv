use ./test
use ./base

fn gendoc {
  var err = ?(mkdir doc)

  test:test $test:tests | test:md (all) > doc/test.md
  test:test $base:tests | test:md (all) > doc/base.md
}

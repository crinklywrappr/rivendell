use ./test
use ./base
use ./fun
use ./lazy
use ./rune
use ./algo
use ./vis

fn gendoc {
  var err = ?(mkdir doc)

  test:test $test:tests | test:md (all) > doc/test.md
  test:test $base:tests | test:md (all) > doc/base.md
  test:test $fun:tests | test:md (all) > doc/fun.md
  test:test $lazy:tests | test:md (all) > doc/lazy.md
  test:test $rune:tests | test:md (all) > doc/rune.md
  test:test $algo:tests | test:md (all) > doc/algo.md
  test:test $vis:tests | test:md (all) > doc/vis.md
}

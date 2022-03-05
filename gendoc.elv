use ./test

fn gendoc {
  var err = ?(mkdir doc)

  test:test $test:tests | test:md (all) > doc/test.md
}

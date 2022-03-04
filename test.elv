use str

fn make-assertion {
  |name f &fixtures=[&] &store=[&]|
  put [&name=$name &f=$f &fixtures=$fixtures &store=$store]
}

fn is-assertion {
  |form|
  and (eq (kind-of $form) map) ^
      has-key $form f ^
      (eq (kind-of $form[f]) fn)
}

fn call-test {
  |test-fn &fixtures=[&] &store=[&]|

  var test-args = $test-fn[arg-names]

  if (and (has-value $test-args fixtures) (has-value $test-args store)) {
    $test-fn $fixtures $store
  } elif (has-value $test-args store) {
    $test-fn $store
  } elif (has-value $test-args fixtures) {
    $test-fn $fixtures
  } else {
    $test-fn
  }
}

fn call-predicate {
  |predicate reality &fixtures=[&] &store=[&]|

  var pred-opts = $predicate[opt-names]

  if (> (count $pred-opts) 0) {
    $predicate $@reality &fixtures=$fixtures &store=$store
  } else {
    $predicate $@reality
  }
}

fn assert {
  |expect predicate &fixtures=[&] &store=[&] &name=assert
   &docstring='base-level assertion.  avoid unless you need a predicate'
   &arglist=[[expect anything 'a function name (str), or the expected value']
             [predicate fn 'single-arity. might have optional fixtures & store']
             [fixtures list 'immutable list']
             [store list 'list which tests can persist changes to']]|
  make-assertion $name {
    |test-fn &store=[&]|

    var new-store = [&]
    var reality err

    # call test
    if (has-value $test-fn[arg-names] store) {
      set new-store @reality = (set err = ?(call-test $test-fn &fixtures=[&] &store=[&]))
    } else {
      set @reality = (set err = ?(call-test $test-fn &fixtures=[&] &store=[&]))
    }

    # call predicate
    var bool @messages = (if (eq $err $ok) {
        if (> (count $reality) 0) {
          call-predicate $predicate $reality &fixtures=$fixtures &store=$store
        } else {
          put $false "test produced no values"
        }
      } else {
        call-predicate $predicate $err &fixtures=$fixtures &store=$store
      })

    # $new-store should be the last thing returned
    put $bool $expect $reality $test-fn[body] $messages $new-store
  } &fixtures=$fixtures &store=$store
}

fn is {
  |expectation &fixtures=[&] &store=[&]|
  assert $expectation {|@reality| 
    and (== (count $reality) 1) ^
        (eq $expectation $@reality)
  } &name=is &fixtures=$fixtures &store=$store
}

fn is-each {
  |expectation &fixtures=[&] &store=[&]|
  assert $expectation {|@reality| 
    eq $expectation $reality
  } &name=is-each &fixtures=$fixtures &store=$store
}

fn is-error {
  |&fixtures=[&] &store=[&]|
  assert exception {|@reality| 
    and (== (count $reality) 1) ^
        (not-eq $@reality $ok) ^
        (eq (kind-of $@reality) exception)
  } &name=is-error &fixtures=$fixtures &store=$store
}

fn is-something {
  |&fixtures=[&] &store=[&]|
  assert something {|@reality|
    var @kinds = (each $kind-of~ $@reality)
    and (> (count $kinds) 0) ^
        (or (has-value $kinds list) ^
            (has-value $kinds map) ^
            (has-value $kinds fn) ^
            (has-value $kinds num) ^
            (has-value $kinds float64) ^
            (has-value $kinds string))
  } &name=is-something &fixtures=$fixtures &store=$store
}

fn is-list {
  |&fixtures=[&] &store=[&]|
  assert list {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) list)
  } &name=is-list &fixtures=$fixtures &store=$store
}

fn is-map {
  |&fixtures=[&] &store=[&]|
  assert map {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) map)
  } &name=is-map &fixtures=$fixtures &store=$store
}

fn is-coll {
  |&fixtures=[&] &store=[&]|
  assert collection {|@reality|
    and (== (count $reality) 1) ^
        (has-value [list map] (kind-of $@reality))
  } &name=is-coll &fixtures=$fixtures &store=$store
}

fn is-fn {
  |&fixtures=[&] &store=[&]|
  assert fn {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) fn)
  } &name=is-fn &fixtures=$fixtures &store=$store
}

fn is-num {
  |&fixtures=[&] &store=[&]|
  assert num {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) num)
  } &name=is-num &fixtures=$fixtures &store=$store
}

fn is-float {
  |&fixtures=[&] &store=[&]|
  assert float64 {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) float64)
  } &name=is-float &fixtures=$fixtures &store=$store
}

fn is-numeric {
  |&fixtures=[&] &store=[&]|
  assert number {|@reality|
    and (== (count $reality) 1) ^
        (has-value [num float64] (kind-of $@reality))
  } &name=is-numeric &fixtures=$fixtures &store=$store
}

fn is-string {
  |&fixtures=[&] &store=[&]|
  assert string {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) string)
  } &name=is-string &fixtures=$fixtures &store=$store
}

fn is-nil {
  |&fixtures=[&] &store=[&]|
  assert nil {|@reality|
    and (== (count $reality) 1) ^
        (eq (kind-of $@reality) nil)
  } &name=is-nil &fixtures=$fixtures &store=$store
}

fn test {
  |tests &break=break &docstring='test runner'|

  var test-elements
  var subheaders = []
  var header @els = $@tests

  if (not-eq (kind-of $header) string) {
    fail 'missing header'
  }

  put $break
  put $header

  for el $els {

    var assertion

    if (eq (kind-of $el) string) {
      put $el
      continue
    }

    put $break

    set header @test-elements = $@el

    if (not-eq (kind-of $header) string) { 
      fail 'missing subheader'
    }

    put $header
    set subheaders = [$@subheaders $header]

    for tel $test-elements {

      var store xs

      if (eq (kind-of $tel) string) {
        put $tel
      } elif (is-assertion $tel) {
        set assertion = $tel
        set store = $assertion[store]
      } elif (eq (kind-of $tel) fn) {
        if (eq $assertion $nil) {
          fail 'no assertion set before '{$tel[def]}
        }
        set @xs store = ($assertion[f] $tel &store=$store)
        put [$header $@xs $store]
      } else {
        fail {$tel}' is invalid'
      }

    }

  }

  put $subheaders
}

fn plain {
  |break @xs subheaders|
  var info-text = {|s| styled $s white }
  var header-text = {|s| styled $s white bold }
  var error-text = {|s| styled $s red }
  var error-text-code = {|s| styled $s red bold italic}
  var success-text = {|s| styled $s green }

  var break-length = (if (< 80 (tput cols)) { put 80 } else { tput cols })
  var break-text = (repeat $break-length (str:from-codepoints 0x2500) | str:join '')

  for x $xs {
    if (eq $x $break) {
      echo $break-text
    } elif (and (eq (kind-of $x) string) (has-value $subheaders $x)) {
      echo ($header-text $x)
    } elif (eq (kind-of $x) list) {
      var name bool expect reality test messages store = $@x
      if $bool {
        echo ($success-text $test)
      } else {
        set expect = (to-string $expect)
        set reality = (to-string $reality)
        echo
        echo ($error-text-code $test)
        echo ($error-text 'EXPECTED: '{$expect})
        echo ($error-text 'GOT: '{$reality})
        echo
      }
    }
  }
}

fn err {
  |break @xs subheaders|
  var header-text = {|s| styled $s white bold underlined }
  var error-text = {|s| styled $s red }
  var error-text-code = {|s| styled $s red bold italic}
  var info-text = {|s| styled $s white italic }
  var info-code = {|s| styled $s white bold italic }

  var break-length = (if (< 80 (tput cols)) { put 80 } else { tput cols })
  var break-text = (repeat $break-length (str:from-codepoints 0x2500) | str:join '')

  for x $xs {
    if (eq (kind-of $x) list) {
      var name bool expect reality test messages store = $@x
      if (not $bool) {
        set expect = (to-string $expect)
        set reality = (to-string $reality)

        echo
        echo ($header-text $name)
        echo ($error-text-code $test)
        echo ($error-text 'EXPECTED: '{$expect})
        echo ($error-text 'GOT: '{$reality})

        if (> (count $store) 0) {
          echo ($header-text STORE)
          echo ($info-code $store)
        }

        if (> (count $messages) 0) {
          echo ($header-text MESSAGES)
          for msg $messages {
            echo ($info-text $msg)
          }
          echo
        }

        echo
        echo $break-text
      }
    }
  }

}

var tests = [Tests
             [make-assertion
              (is-map)
              { make-assertion foo { } }
              { make-assertion foo { } &fixtures=[&]}
              { make-assertion foo { } &store=[&]}
              { make-assertion foo { } &fixtures=[&] &store=[&]}]

             [is-assertion
              (assert assertion $is-assertion~)
              { make-assertion foo { put foo } }

              '`is-assertion` only cares about the presence of `f` key'
              { make-assertion foo { } | dissoc (all) fixtures | dissoc (all) store }

              'All other assertions satisfy the predicate'
              { assert foo { put $true } }
              { is foo }
              { is-each [foo bar] }
              { is-error }
              { is-something }
              { is-list }
              { is-map }
              { is-coll }
              { is-fn }
              { is-num }
              { is-float }
              { is-numeric }
              { is-string }
              { is-nil }]

             [helpers
              'these functions are useful if you are writing a low-level assertion like `assert`'
              (is something)
              { call-test {|| put something} }

              (is bar)
              { call-test {|store| put $store[foo]} &store=[&foo=bar] }

              (is bar)
              { call-test {|fixtures| put $fixtures[foo]} &fixtures=[&foo=bar] }

              (is-each [b y])
              { call-test {|fixtures store| put $fixtures[a]; put $store[x]} &fixtures=[&a=b] &store=[&x=y] }
              ]]

# Tests
1. [make-assertion](#make-assertion)
2. [is-assertion](#is-assertion)
3. [helpers](#helpers)
4. [assert](#assert)
5. [high-level-assertions](#high-level-assertions)
6. [test-runner-exceptions](#test-runner-exceptions)
7. [working-test-runner](#working-test-runner)
***
## make-assertion
```elvish
make-assertion foo { } 
```
```elvish
▶ [&name=foo &f=<closure 0xc00038a600> &store=[&] &fixtures=[&]]
```
```elvish
make-assertion foo { } &fixtures=[&]
```
```elvish
▶ [&name=foo &f=<closure 0xc000308000> &store=[&] &fixtures=[&]]
```
```elvish
make-assertion foo { } &store=[&]
```
```elvish
▶ [&name=foo &f=<closure 0xc000308540> &store=[&] &fixtures=[&]]
```
```elvish
make-assertion foo { } &fixtures=[&] &store=[&]
```
```elvish
▶ [&name=foo &f=<closure 0xc0003080c0> &store=[&] &fixtures=[&]]
```
***
## is-assertion
```elvish
make-assertion foo { put foo } 
```
```elvish
▶ [&name=foo &f=<closure 0xc000360180> &store=[&] &fixtures=[&]]
```
 
`is-assertion` only cares about the presence of `f` key
```elvish
make-assertion foo { } | dissoc (all) fixtures | dissoc (all) store 
```
```elvish
▶ [&name=foo &f=<closure 0xc0006e2000>]
```
 
All other assertions satisfy the predicate
```elvish
assert foo { put $true } 
```
```elvish
▶ [&name=assert &f=<closure 0xc00038acc0> &store=[&] &fixtures=[&]]
```
```elvish
is-one foo 
```
```elvish
▶ [&name=is-one &f=<closure 0xc00038b440> &store=[&] &fixtures=[&]]
```
```elvish
is-each foo bar 
```
```elvish
▶ [&name=is-each &f=<closure 0xc000308cc0> &store=[&] &fixtures=[&]]
```
```elvish
is-error 
```
```elvish
▶ [&name=is-error &f=<closure 0xc000361200> &store=[&] &fixtures=[&]]
```
```elvish
is-something 
```
```elvish
▶ [&name=is-something &f=<closure 0xc00038b740> &store=[&] &fixtures=[&]]
```
```elvish
is-nothing 
```
```elvish
▶ [&name=is-nothing &f=<closure 0xc000309980> &store=[&] &fixtures=[&]]
```
```elvish
is-list 
```
```elvish
▶ [&name=is-list &f=<closure 0xc00037a180> &store=[&] &fixtures=[&]]
```
```elvish
is-map 
```
```elvish
▶ [&name=is-map &f=<closure 0xc0006e26c0> &store=[&] &fixtures=[&]]
```
```elvish
is-coll 
```
```elvish
▶ [&name=is-coll &f=<closure 0xc0003615c0> &store=[&] &fixtures=[&]]
```
```elvish
is-fn 
```
```elvish
▶ [&name=is-fn &f=<closure 0xc0006e2c00> &store=[&] &fixtures=[&]]
```
```elvish
is-num 
```
```elvish
▶ [&name=is-num &f=<closure 0xc0006e3200> &store=[&] &fixtures=[&]]
```
```elvish
is-string 
```
```elvish
▶ [&name=is-string &f=<closure 0xc0006eefc0> &store=[&] &fixtures=[&]]
```
```elvish
is-nil 
```
```elvish
▶ [&name=is-nil &f=<closure 0xc000309380> &store=[&] &fixtures=[&]]
```
***
## helpers
 
These functions are useful if you are writing a low-level assertion like `assert`.  Your test function can be one of four forms, and `call-test` will dispatch based on argument-reflection.
 
The following tests demonstrate that type of dispatch.
```elvish
call-test {|| put something} 
```
```elvish
▶ something
```
```elvish
call-test {|store| put $store[x]} &store=[&x=foo] 
```
```elvish
▶ foo
```
```elvish
call-test {|fixtures| put $fixtures[x]} &fixtures=[&x=bar] 
```
```elvish
▶ bar
```
```elvish
call-test {|fixtures store| put $fixtures[x]; put $store[x]} &fixtures=[&x=foo] &store=[&x=bar] 
```
```elvish
▶ foo
▶ bar
```
 
`call-test` expects fixtures before store.  This test errors because the input args are swapped.
```elvish
call-test {|store fixtures| put $fixtures[a]; put $store[b]} &fixtures=[&a=a] &store=[&b=b] 
```
```elvish
▶ [&reason=<unknown no such key: a>]
```
 
`call-predicate` accepts two forms.
```elvish
call-predicate {|@reality| eq $@reality foo} foo 
   call-predicate {|@reality &fixtures=[&] &store=[&]|
     == ($reality[0] $fixtures[x] $store[x]) -1
   } $compare~ &fixtures=[&x=1] &store=[&x=2]
```
```elvish
▶ $true
```
 
Any other form will error
```elvish
call-predicate {|@reality &store=[&]| eq $@reality foo} foo 
```
```elvish
▶ [&reason=<unknown unsupported option: fixtures>]
```
```elvish
call-predicate {|@reality &fixtures=[&]| eq $@reality foo} foo 
```
```elvish
▶ [&reason=<unknown unsupported option: store>]
```
***
## assert
 
assertions return the boolean result, the expected value, the values emmited from the test, the test body, any messages produced by the assertion, and the store (more on that later)
```elvish
(assert foo {|@x| eq $@x foo})[f] { put foo } 
```
```elvish
▶ [&test='put foo ' &expect=foo &bool=$true &store=[&] &messages=[] &reality=[foo]]
```
 
The expected value can be the exact value you want, or it can be a description of what you are testing for
```elvish
(assert string-with-foo {|@x| str:contains $@x foo})[f] { put '--foo--' } | put (all)[expect] 
```
```elvish
▶ string-with-foo
```
 
if your predicate takes a store, then the predicate must emit the store first
```elvish
 assoc $store foo bar; put foo 
```
```elvish
▶ foo
```
```elvish
test [mytest [subheader {|store| put foo} ]] 
```
```elvish
▶ [&reason=[&content='no assertion before {|store| put foo}' &type=fail]]
```
 
The `store` must be returned as a map
```elvish
test [mytest [subheader {|store| put foo; put bar} ]] 
```
```elvish
▶ [&reason=[&content='no assertion before {|store| put foo; put bar}' &type=fail]]
```
***
## high-level-assertions
 
general use-cases for each assertion
```elvish
(is-one foo)[f] { put foo } | put (one)[bool] 
(is-each foo bar)[f] { put foo; put bar } | put (one)[bool] 
(is-error)[f] { fail foobar } | put (one)[bool] 
(is-something)[f] { put foo; put bar; put [foo bar] } | put (one)[bool] 
(is-nothing)[f] { } | put (one)[bool] 
(is-list)[f] { put [a b c] } | put (one)[bool] 
(is-map)[f] { put [&foo=bar] } | put (one)[bool] 
(is-fn)[f] { put { } } | put (one)[bool] 
(is-string)[f] { put foo } | put (one)[bool] 
(is-nil)[f] { put $nil } | put (one)[bool] 
```
```elvish
▶ $true
```
 
`is-coll` works on lists and maps
```elvish
(is-coll)[f] { put [a b c] } | put (one)[bool] 
(is-coll)[f] { put [&foo=bar] } | put (one)[bool] 
```
```elvish
▶ $true
```
 
`is-num` works on nums & floats.  It could expand to more types if elvish adds more in the future.
```elvish
(is-num)[f] { num 1 } | put (one)[bool] 
(is-num)[f] { float64 1 } | put (one)[bool] 
```
```elvish
▶ $true
```
 
`is-ok` does not exist (yet), but you can get it with this.  In this example `{ put foo }` is the function we are testing for success.  We don not care about the return value - only that the function works without error
```elvish
(is-one $ok)[f] { var @_ = (var err = ?({ put foo })); put $err } | put (one)[bool] 
```
```elvish
▶ $true
```
 
Simply returning something is not enough for `is-something`.  A bunch of `$nil` values will fail, for instance
```elvish
(is-something)[f] { put $nil; put $nil; put $nil } | put (one)[bool] 
```
```elvish
▶ $false
```
***
## test-runner-exceptions
 
The test runner emits information suitable for debugging and documentation.  Start by giving it nothing.
```elvish
test $nil 
```
```elvish
▶ [&reason=[&content='tests must be a list' &type=fail]]
```
 
It should have told you it expects a list.  Give it a list.
```elvish
test [] 
```
```elvish
▶ [&reason=[&content='missing header' &type=fail]]
```
 
Now it is complaining about a missing header.  Give it a header.
```elvish
test [mytests] 
```
```elvish
▶ break
▶ mytests
▶ []
```
 
Our first victory!  But we have no tests yet.  A test is a function preceded by an assertion.  They are grouped in sub-lists.  First, test all the ways we can get that wrong.
 
$nil is not a list
```elvish
test [mytests $nil] 
```
```elvish
▶ [&reason=[&content='expected list or string, got nil' &type=fail]]
```
 
This is missing a subheader
```elvish
test [mytests []] 
```
```elvish
▶ [&reason=[&content='missing subheader' &type=fail]]
```
 
This is missing an assertion
```elvish
test [mytests ['bad test' { }]] 
```
```elvish
▶ [&reason=[&content='no assertion before { }' &type=fail]]
```
***
## working-test-runner
 
an arbitrary number of tests can follow an assertion, and text can be added to describe the tests
```elvish
   test [mytests
     [foo-tests
       'All of the assertions the string "foo" satisfies'
       (is-string)
       { put foo }
       
       (is-something)
       { put foo}
       
       'Really, text can be added anywhere'
       (is-one foo)
       { put foo }]]
```
```elvish
▶ break
▶ mytests
▶ break
▶ foo-tests
▶ All of the assertions the string "foo" satisfies
▶ [&test='put foo ' &expect=string &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ [&test='put foo' &expect=something &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ Really, text can be added anywhere
▶ [&test='put foo ' &expect=foo &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ [foo-tests]
```
 
Assertions which compose other assertions and predicates are planned.
 
Fixtures can be supplied to tests.  They must be maps set in the assertion.
```elvish
   test [mytests
     [fixture-test
       (is-one bar &fixtures=[&foo=bar])
       {|fixtures| put $fixtures[foo]}]]
```
```elvish
▶ break
▶ mytests
▶ break
▶ fixture-test
▶ [&test=' put $fixtures[foo]' &expect=bar &bool=$true &store=[&] &subheader=fixture-test &messages=[] &reality=[bar]]
▶ [fixture-test]
```
 
Stores can be supplied to tests, too.  These must be maps, too.  Stores persist changes from test to test and are reset with every assertion.
```elvish
   test [mytests
     [store-test
       (assert whaky-test {|@results &fixtures=[&] &store=[&]|
         if (eq $store[x] foo) {
           eq $store[y] bar
         } elif (eq $store[x] bar) {
           eq $store[y] foo
         }
       })
       {|store| assoc $store x foo | assoc (one) y bar }
       {|store|
         if (eq $store[x] foo) {
           assoc $store x bar | assoc (one) y foo
         } else {
           put [&]
         }
       }]]
```
```elvish
▶ break
▶ mytests
▶ break
▶ store-test
▶ [&test=' assoc $store x foo | assoc (one) y bar ' &expect=whaky-test &bool=$true &store=[&x=foo &y=bar] &subheader=store-test &messages=[] &reality=[]]
▶ [&test="\n                         if (eq $store[x] foo) {\n                           assoc $store x bar | assoc (one) y foo\n                         } else {\n                           put [&]\n                         }\n                       " &expect=whaky-test &bool=$true &store=[&x=bar &y=foo] &subheader=store-test &messages=[] &reality=[]]
▶ [store-test]
```
 
A store can be initialized from an assertion also.
```elvish
   test [mytests
     [store-test
       (is-one bar &store=[&foo=bar])
       {|store| put $store; put $store[foo]}]]
```
```elvish
▶ break
▶ mytests
▶ break
▶ store-test
▶ [&test=' put $store; put $store[foo]' &expect=bar &bool=$true &store=[&foo=bar] &subheader=store-test &messages=[] &reality=[bar]]
▶ [store-test]
```
 
However, when taking a store, the store must be the first element returned, even if no changes are made
```elvish
   test [mytests
     [store-test
       (is-one bar &store=[&foo=bar])
       {|store| put $store[foo]}]]
```
```elvish
▶ [&reason=[&content='test  put $store[foo] took store but did not emit store as a map.  response[0]=bar' &type=fail]]
```

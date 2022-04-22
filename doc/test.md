# Test.elv
1. [testing-status](#testing-status)
2. [make-assertion](#make-assertion)
3. [is-assertion](#is-assertion)
4. [helpers](#helpers)
5. [assert](#assert)
6. [high-level-assertions](#high-level-assertions)
7. [test-runner-exceptions](#test-runner-exceptions)
8. [working-test-runner](#working-test-runner)
***
## testing-status
62 tests passed out of 62

100% of tests are passing

***
## make-assertion
 
lowest-level building-block for constructing assertions.  This makes assertion creation a bit easier by defaulting fixtures and store to empty maps.  This document will explain those later.
```elvish
make-assertion foo { } { }
▶ [&name=foo &f=<closure 0xc0006b6b40> &pred=<closure 0xc0006b6c00> &store=[&] &fixtures=[&]]
```
```elvish
make-assertion foo { } { } &fixtures=[&foo=bar]
▶ [&name=foo &f=<closure 0xc000a94f00> &pred=<closure 0xc000a94fc0> &store=[&] &fixtures=[&foo=bar]]
```
```elvish
make-assertion foo { } { } &store=[&frob=nitz]
▶ [&name=foo &f=<closure 0xc0002940c0> &pred=<closure 0xc000294180> &store=[&frob=nitz] &fixtures=[&]]
```
```elvish
make-assertion foo { } { } &fixtures=[&foo=bar] &store=[&frob=nitz]
▶ [&name=foo &f=<closure 0xc000294240> &pred=<closure 0xc000294300> &store=[&frob=nitz] &fixtures=[&foo=bar]]
```
***
## is-assertion
 
`is-assertion` is a predicate for assertions.
```elvish
make-assertion foo { put foo } { } | is-assertion (one)
▶ $true
```
 
`is-assertion` only cares about the presence of `f` key
```elvish
make-assertion foo { } { } | dissoc (one) fixtures | dissoc (one) store | is-assertion (one)
▶ $true
```
 
All other assertions satisfy the predicate
```elvish
assert foo { put $true } | is-assertion (one)
is-one foo | is-assertion (one)
is-each foo bar | is-assertion (one)
is-error | is-assertion (one)
is-something | is-assertion (one)
is-nothing | is-assertion (one)
is-list | is-assertion (one)
is-map | is-assertion (one)
is-coll | is-assertion (one)
is-fn | is-assertion (one)
is-num | is-assertion (one)
is-string | is-assertion (one)
is-nil | is-assertion (one)
```
```elvish
▶ $true
```
***
## helpers
 
These functions are useful if you are writing a low-level assertion like `assert`.  Your test function can be one of four forms, and `call-test` will dispatch based on argument-reflection.
 
The following tests demonstrate that type of dispatch.
```elvish
call-test {|| put something}
call-test {|store| put $store[x]} &store=[&x=something]
call-test {|fixtures| put $fixtures[x]} &fixtures=[&x=something]
```
```elvish
▶ something
```
```elvish
call-test {|fixtures store| put $fixtures[x]; put $store[x]} &fixtures=[&x=some] &store=[&x=thing]
▶ some
▶ thing
```
 
`call-test` expects fixtures before store.  This test errors because the input args are swapped.
```elvish
call-test {|store fixtures| put $fixtures[a]; put $store[b]} &fixtures=[&a=a] &store=[&b=b]
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
▶ [&reason=<unknown unsupported option: fixtures>]
```
```elvish
call-predicate {|@reality &fixtures=[&]| eq $@reality foo} foo
▶ [&reason=<unknown unsupported option: store>]
```
***
## assert
 
assertions return the boolean result, the expected value, the values emmited from the test, the test body, any messages produced by the assertion, and the store (more on that later)
```elvish
(assert foo {|@x| eq $@x foo})[f] { put foo }
▶ [&test='put foo' &expect=foo &bool=$true &store=[&] &messages=[] &reality=[foo]]
```
 
The expected value can be the exact value you want, or it can be a description of what you are testing for
```elvish
(assert string-with-foo {|@x| str:contains $@x foo})[f] { put '--foo--' } | put (all)[expect]
▶ string-with-foo
```
 
if your predicate takes a store, then the predicate must emit the store first
```elvish
assoc $store foo bar; put foo
▶ [&foo=bar]
▶ foo
```
```elvish
test [mytest [subheader {|store| put foo} ]]
▶ [&reason=[&content='no assertion before {|store| put foo}' &type=fail]]
```
 
The `store` must be returned as a map
```elvish
test [mytest [subheader (is-one bar) {|store| put foo; put bar} ]]
▶ [&reason=[&content='test  put foo; put bar took store but did not emit store as a map.  response[0]=foo' &type=fail]]
```
***
## high-level-assertions
 
general use-cases for each assertion
```elvish
(is-one foo)[f] { put foo } | put (one)[bool]
(is-each foo bar)[f] { put foo; put bar } | put (one)[bool]
(is-error)[f] { fail foobar } | put (one)[bool]
(is-ok)[f] { put foobar } | put (one)[bool]
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
 
`is-ok` does not exist (yet), but you can get it with this.  In this example `{ put foo }` is the function we are testing for success.  We do not care about the return value - only that the function works without error
```elvish
(is-one $ok)[f] { var @_ = (var err = ?({ put foo })); put $err } | put (one)[bool]
▶ $true
```
```elvish
(is-ok)[f] { fail foobar } | put (one)[bool]
▶ $false
```
 
Simply returning something is not enough for `is-something`.  A bunch of `$nil` values will fail, for instance
```elvish
(is-something)[f] { put $nil; put $nil; put $nil } | put (one)[bool]
▶ $false
```
***
## test-runner-exceptions
 
The test runner emits information suitable for debugging and documentation.  Start by giving it nothing.
```elvish
test $nil
▶ [&reason=[&content='tests must be a list' &type=fail]]
```
 
It should have told you it expects a list.  Give it a list.
```elvish
test []
▶ [&reason=[&content='missing header' &type=fail]]
```
 
Now it is complaining about a missing header.  Give it a header.
```elvish
test [mytests]
▶ break
▶ mytests
▶ []
```
 
Our first victory!  But we have no tests yet.  A test is a function preceded by an assertion.  They are grouped in sub-lists.  First, test all the ways we can get that wrong.
 
$nil is not a list
```elvish
test [mytests $nil]
▶ [&reason=[&content='expected list or string, got nil' &type=fail]]
```
 
This is missing a subheader
```elvish
test [mytests []]
▶ [&reason=[&content='missing subheader' &type=fail]]
```
 
This is missing an assertion
```elvish
test [mytests ['bad test' { }]]
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
▶ break
▶ mytests
▶ break
▶ foo-tests
▶ All of the assertions the string "foo" satisfies
▶ [&test='put foo' &expect=string &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ [&test='put foo' &expect=something &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ Really, text can be added anywhere
▶ [&test='put foo' &expect=foo &bool=$true &store=[&] &subheader=foo-tests &messages=[] &reality=[foo]]
▶ [foo-tests]
```
 
Assertions which compose other assertions and predicates are planned.
 
Fixtures can be supplied to tests.  They must be maps set in the assertion.
```elvish
   test [mytests
     [fixture-test
       (is-one bar &fixtures=[&foo=bar])
       {|fixtures| put $fixtures[foo]}]]
▶ break
▶ mytests
▶ break
▶ fixture-test
▶ [&test='put $fixtures[foo]' &expect=bar &bool=$true &store=[&] &subheader=fixture-test &messages=[] &reality=[bar]]
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
▶ break
▶ mytests
▶ break
▶ store-test
▶ [&test='assoc $store x foo | assoc (one) y bar' &expect=whaky-test &bool=$true &store=[&x=foo &y=bar] &subheader=store-test &messages=[] &reality=[[&x=foo &y=bar]]]
▶ [&test="\n              if (eq $store[x] foo) {\n                assoc $store x bar | assoc (one) y foo\n              } else {\n                put [&]\n              }\n" &expect=whaky-test &bool=$true &store=[&x=bar &y=foo] &subheader=store-test &messages=[] &reality=[[&x=bar &y=foo]]]
▶ [store-test]
```
 
A store can be initialized from an assertion also.
```elvish
   test [mytests
     [store-test
       (is-one bar &store=[&foo=bar])
       {|store| put $store; put $store[foo]}]]
▶ break
▶ mytests
▶ break
▶ store-test
▶ [&test='put $store; put $store[foo]' &expect=bar &bool=$true &store=[&foo=bar] &subheader=store-test &messages=[] &reality=[[&foo=bar] bar]]
▶ [store-test]
```
 
However, when taking a store, the store must be the first element returned, even if no changes are made
```elvish
   test [mytests
     [store-test
       (is-one bar &store=[&foo=bar])
       {|store| put $store[foo]}]]
▶ [&reason=[&content='test  put $store[foo] took store but did not emit store as a map.  response[0]=bar' &type=fail]]
```

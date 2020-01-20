# TODO
# vars ns - put all vars/fns in an ns
# find-doc regex - prints all docs matching regex

use str

use ./base
use ./fun
use ./rune
use ./vis

fn source [f &docstring='Prints the source code 
                         of a given function'
             &arglist=[[f fn 'a function repr']]]{
  echo $f[def]
}

fn doc [f &docstring='Prints the signature, docstring, 
                      & arglist of the given function'
          &arglist=[[f fn 'a function repr']]]{

  f-args = $f[arg-names]
  if (not-eq $f[rest-arg] '') {
    f-args = (base:append $f-args '@'{$f[rest-arg]})
  }

  f-opts = (fun:zipmap $f[opt-names] $f[opt-defaults])

  sig-opts = (dissoc $f-opts docstring | dissoc (all) arglist)

  signature = (if (> (count $sig-opts) 0) {
        base:append $f-args (to-string $sig-opts)[1:-1]
      } else {
        put $f-args
      })
  signature = (joins ' ' $signature)

  @docstring = (if (has-key $f-opts docstring) {
        splits "\n" $f-opts[docstring] |
          each $str:trim-space~ |
          joins ' ' |
          rune:cell-format (tput cols) (all)
      } else {
        put ''
      })

  @arglist = (if (has-key $f-opts arglist) {
        each \
          (fun:partial $fun:zipmap~ [arg type desc]) \
          $f-opts[arglist]
      } else {
        put [&]
      })

  echo '['{$signature}']'

  if (> (count $docstring[0]) 0) {
    echo
    each $echo~ $docstring
  }

  if (> (count $arglist[0]) 0) {
    echo
    vis:sheety $@arglist &keys=[arg type desc]
  }
}

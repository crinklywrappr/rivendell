fn matches [a]{
  put [@b]{
    tf = (eq $@b $a)

    put $tf
    if (not $tf) {
      put {$@b}" != "{$a}
    }
  }
}

fn is-error [@a]{
  c = (count $a)
  tf = (and  \
      (== $c 1) \
      (not-eq $a $ok) \
      (eq (kind-of $a) exception))

  put $tf
  if (not $tf) {
    put "Expected an exception - instead got "{$a}
  }
}

fn something [@a]{
  c = (count $a)
  tf = (and (> $c 0) \
      (not-eq (kind-of $a[0]) exception))

  put $tf
  if (not $tf) {
    put "Test did not output anything"
  }
}

# t is a testing fn like matches, is-error, & something.
# it takes var-args and returns a boolean followed by 
# any number of messages.  messages will be shown if it
# the boolean is false
fn test [nm t f @arr &show-success=$false]{
  border = (repeat (tput cols) '-' | joins '')
  echo $border
  echo "RUNNING TEST "{$nm}"...."

  @res = (err = ?($f $@arr))
  
  echo "\u001b[1ATESTING OUTPUT FOR "{$nm}"...."

  tf @msgs = (if (eq $err $ok) {
    $t $@res
  } else {
    $t $err
  })

  if $tf {
    echo "\u001b[1A\u001b[2K\033[;32;1mSUCCESS: "{$nm}"\033[0m"
    if $show-success {
      echo "\033[;32;22m-------"
      if (> (count $res) 0) {
        for r $res {
          echo (to-string $r)
        }
      }
      if (not-eq $err $ok) {
        echo $err
      }
      echo "-------\033[0m"
    }
  } else {
    echo "\u001b[1A\u001b[2K\033[;31;1mFAILURE: "{$nm}"\033[0m"
    if (> (count $msgs) 0) {
      echo "\033[;31;22m-------"
      each $echo~ $msgs
      echo "-------\033[0m"
    }
  }

  echo $border
}

fn runner [forms &show-success=$false]{
  for form $forms {
    try {
      nm t f @arr = (explode $form)
      valid = (and (eq (kind-of $nm) string) \
          (eq (kind-of $t) fn) \
          (eq (kind-of $f) fn))

      if (not $valid) {
        fail invalid
      }

      try {
        test $nm $t $f $@arr &show-success=$show-success
      } except {
        echo "\033[;31;1mERROR DURING TEST: "{$nm}"\033[0m"
      }

    } except {
      s = (to-string $form)
      echo "\033[;31;1mBAD TEST FORM: "{$s}"\033[0m"
    }
  }
}

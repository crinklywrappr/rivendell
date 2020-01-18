fn matches [a]{
  put [@b]{
    tf = (eq $@b $a)

    put $tf
    if (not $tf) {
      try {
        sb = (to-string $@b)
        sa = (to-string $a)
        put {$sb}" != "{$sa}
      } except {
        put "Did not match expected result"
      }
    }
  }
}

fn is-error [@a]{
  c = (count $a)
  tf = (and \
      (== $c 1) \
      (not-eq $a $ok) \
      (eq (kind-of $a) exception))

  put $tf
  if (not $tf) {
    try {
      s = (to-string $a)
      put "Expected an exception - instead got "{$s}
    } except {
      put "Expected an exception - none raised"
    }
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
      for r $res {
        s = (to-string $r)
        echo "\033[;32;22m"{$s}"\033[0m"
      }
      if (not-eq $err $ok) {
        echo $err
      }
    }
  } else {
    echo "\u001b[1A\u001b[2K\033[;31;1mFAILURE: "{$nm}"\033[0m"
    for m $msgs {
      echo "\033[;31;22m"{$m}"\033[0m"
    }
  }
}

fn runner [forms &show-success=$false]{
  for form $forms {
    try {
      border = (repeat (tput cols) (chr 0x2500) | joins '')
      echo $border

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

fn each-matches [a]{
  put [b]{
    tf = (eq $b $a)

    put $tf

    if (not $tf) {
      sb = (to-string $b)
      sa = (to-string $a)
      put {$sb}" != "{$sa}
    }
  }
}

fn matches [a]{
  put [b]{
    tf = (eq $@b $a)

    put $tf
    if (not $tf) {
      sb = (to-string $@b)
      sa = (to-string $a)
      put {$sb}" != "{$sa}
    }
  }
}

fn is-error [a]{
  tf = (and (not-eq $a $ok) \
      (eq (kind-of $a) exception))

  put $tf
  if (not $tf) {
    s = (to-string $a)
    put "Expected an exception - instead got "{$s}
  }
}

fn something [a]{
  tf = (and (not-eq (kind-of $a) exception) \
      (> (count $a) 0))

  put $tf
  if (not $tf) {
    put "Test did not output anything"
  }
}

# t is a testing fn like matches, is-error, & something.
# it takes an arg and returns a boolean followed by 
# any number of messages.  messages will be shown if
# the boolean is false
fn test [nm t f &show-success=$false &show-messages=$true]{
  echo "RUNNING TEST "{$nm}"...."

  @res = (err = ?($f))
  
  echo "\u001b[1ATESTING OUTPUT FOR "{$nm}"...."

  tf @msgs = (if (eq $err $ok) {
    $t $res
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
    if $show-messages {
      for m $msgs {
        echo "\033[;31;22m"{$m}"\033[0m"
      }
    }
  }
}

fn runner [forms &show-success=$false &show-messages=$true]{
  
  exec-form = [nm t f]{
        try {
          test $nm $t $f &show-success=$show-success &show-messages=$show-messages
        } except {
          echo "\033[;31;1mERROR DURING TEST: "{$nm}"\033[0m"
        }
      }

  for form $forms {
    try {
      border = (repeat (tput cols) (chr 0x2500) | joins '')
      echo $border

      nm t @fs = (explode $form)
      valid = (and (eq (kind-of $nm) string) \
          (eq (kind-of $t) fn))

      if (not $valid) {
        fail invalid
      }

      i = 1
      for f $fs {
        $exec-form {$nm}" ("{$i}")" $t $f
        i = (+ $i 1)
      }
    } except {
      s = (to-string $form)
      echo "\033[;31;1mBAD TEST FORM: "{$s}"\033[0m"
    }
  }
}

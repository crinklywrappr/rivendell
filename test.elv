fn matches [a b]{
  tf = (eq $a $b)

  put $tf
  if (not $tf) {
    put {$a}" != "{$b}
  }
}

fn is-error [a]{
  tf = (and (not-eq $a $ok) \
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
        each $echo~ $res
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

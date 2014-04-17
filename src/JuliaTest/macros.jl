macro s(exp)
  colorNumber = int(hash(exp.args[1]) % 6) + 1
  quote
    print("\e[3", $colorNumber, "m")
    println($(string(exp)), " => ",$(esc(exp)))
    print($RESET)
  end
end

macro p(exp...)
  len = length(exp)
  if len == 1
    str, = exp
    :(println($(esc(str))))
  else
    name, str = exp
    colorNumber = int(hash(name) % 6) + 1
    :(println("\e[3",$colorNumber,"m",$(string(name)),": ",$(esc(str)),$RESET))
  end
end

macro l(args...)
  char, n, len = '-', 30, length(args)
  if len == 1
    char = args[1]
  else len == 2
    n, char = args
  end
  quote println(string($char) ^ $n) end
end

macro pp(exp...)
  quote
    [print(i,' ') for i in $exp]
    print('\n')
  end
end

macro d(exp...)
  :(dump($(exp...)))
end

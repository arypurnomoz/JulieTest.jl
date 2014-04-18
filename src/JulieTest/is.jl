function singular(cond)
  quote let
    local expected = $(string(cond))
    $(esc(cond)) || error("$expected, turns out to be false")
  end end
end

function exact(cond,prediction)
  quote let
    local got = $(esc(cond))
    local expected = $(esc(prediction))
    local isPass = typeof(expected) <: Function ? expected(got): expected == got
    isPass || error("got $(repr(got)), expected to be $(repr(expected))")
  end end
end

function singleConditiontest(cond,leftMost,prediction)
  quote let
    local condition = $(esc(cond))
    local expected = $(esc(prediction))
    local fn = $(esc(leftMost))
    fn(condition, expected) || error("got $(repr(condition)), expected to be $fn $(repr(expected))")
  end end
end

function multipleConditionTest(cond,prediction,rightMostFn,fns)
  quote let
    local condition = $(esc(cond))
    local expected= $(esc(prediction))
    local rightMostFn = $(esc(rightMostFn))
    local fns = $(Expr(:vcat,reverse(fns)...))
    local allTrue = rightMostFn(condition,expected)
    local fn
    for fn in fns
      allTrue = fn(allTrue)
    end
    allTrue || error("got $(repr(condition)), expected to be $(join(fns,' ')) $rightMostFn $(repr(expected))")
  end end
end

macro is(args...)
  len = length(args)
  test, = args
  cond, leftMost = test.args
  if len == 1
    if test.head == :(=>)
      exact(test.args...)
    else
      singular(test)
    end
  elseif len > 2
    multipleConditionTest(cond,args[end], args[end - 1], [leftMost, [args[i] for i in 2:(len- 2)]])
  else
    singleConditiontest(cond,leftMost,args[end])
  end
end

not(x) = x == false
not(x,y) = x != y

truthy(x) = x != false
falsy(x) = !truthy(x)
falsey = falsy

above(x,y) = x > y
above{T<:Array}(array::T,x) = length(array) > x
isAbove = isabove = above

least(x,y) = x >= y
least{T<:Array}(array::T,x) = length(array) >= x
atleast = atLeast = least

below(x,y) = x < y
below{T<:Array}(array::T,x) = below(array) < x
isbelow = isBelow = below

most(x,y) = x <= y
most{T<:Array}(array::T,x) = below(array) <= x
ismost = isMost = most

empty(x) = length(x) == 0

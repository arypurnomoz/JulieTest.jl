type Description
  name::String
  fn::Function
  depth::Int
  children
  function Description(name::String,fn::Function,depth::Int)
    new(name,fn,depth,{})
  end
end

type Test
  name::String
  desc::Description
  fn::Function
end

type Error
  test::Test
  err
  trace
end

type DescriptionError
  desc::Description
  err
  trace
end

descPrefix = ""
currDesc = None
depth = 0
descriptions = Description[]
passes = Test[]
errors = Union(Error,DescriptionError)[]

function run(test::Test)
  fin = 0
  try
    t0 = time()
    test.fn()
    fin = time() - t0
  catch e
    err = Error(test,e,catch_backtrace())
    failedReport(err)
    return push!(errors, err)
  end
  passReport(test, toMilis(fin))
  push!(passes,test)
end

function run{T<:Array}(suite::T)
  for test in suite
    run(test)
  end
end

function run(desc::Description)
  global currDesc, descPrefix, depth
  currDesc = desc
  depth = desc.depth
  try
    desc.fn()
    report(desc)
    run(desc.children)
  catch e
    err = DescriptionError(desc,e,catch_backtrace())
    failedReport(err)
    push!(errors, err)
  end
end

function run()
  global descriptions, passes, errors, descPrefix, depth
  t0 = time()
  run(descriptions)
  summaryReport(passes,errors, toMilis(time() - t0))
  totalError = length(errors)
  
  totalError == 0  || fullFailedReport(errors)
  
  
  # Reset the global variables
  tests = None
  descPrefix = ""
  depth = 0
  empty!(descriptions)
  empty!(passes)
  empty!(errors)
  
  println('\n',"\033[33mAll test finished running\n", RESET)
  return totalError
end

function describe(fn::Function, name::String)
  global descriptions, descPrefix, depth
  push!(descriptions, Description(name,fn,depth + 1))
end

function it(fn::Function, name::String)
  push!(currDesc.children, Test(name,currDesc,fn))
end
  
_describe(args...) = begin end
_it(args...) = begin end


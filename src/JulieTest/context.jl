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
  iit::Bool
  function Test(name::String, desc::Description, fn::Function, iit::Bool)
    new(name,desc,fn,iit)
  end
  function Test(name::String, desc::Description, fn::Function)
    new(name,desc,fn,false)
  end
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

noob() = begin end
depth = 0
iitOn = false
iitTests= Test[]
descriptions = Description("", noob,0)
passes = Test[]
errors = Union(Error,DescriptionError)[]
currDesc = descriptions

function run(test::Test)
  iitOn && !test.iit && return
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
  global currDesc, depth
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
  global descriptions, passes, errors, depth, iitOn, iitTests, currDesc
  t0 = time()
  run(descriptions)
  summaryReport(passes,errors, toMilis(time() - t0))
  
  # Reset the global variables
  tests = None
  depth = 0
  iitOn = false
  empty!(descriptions.children)
  empty!(passes)
  empty!(errors)
  currDesc = descriptions
  
  println('\n',"\033[33mAll test finished running\n", RESET)
  return length(errors)
end

function describe(fn::Function, name::String)
  global currDesc, depth
  push!(currDesc.children, Description(name,fn,depth + 1))
end

function it(fn::Function, name::String)
  push!(currDesc.children, Test(name,currDesc,fn))
end

function iit(fn::Function, name::String)
  global iitOn = true
  push!(currDesc.children, Test(name,currDesc,fn,true))
end
  
_describe(args...) = begin end
_it(args...) = begin end


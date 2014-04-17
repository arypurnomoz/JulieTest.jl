module JuliaTest

include("JuliaTest/macros.jl")
include("JuliaTest/context.jl")
include("JuliaTest/is.jl")
#=include("reporter/spec.jl")=#

export 
  # reporter
  typeReport,
  
  #context
  describe, _describe, it, iit, _it,
  
  # @is
  @is,
  falsy, falsey, truthy, not,
  
  # comparision
  least, atleast, atLeast,
  most, ismost, isMost,
  above, isabove, isAbove,
  below, isbelow, isBelow,

  # array
  empty,
  
  # macros
  @p, @l, @d, @pp, @s
  
reporterLoaded = false

function runTests()
  global reporterLoaded 
  reporterLoaded || reporter("spec")
  run()
end
  
function reporter(str::String)
  global reporterLoaded = true
  str == "" && return
  filepath = joinpath(Pkg.dir(), "JuliaTest/src/reporter", str * ".jl")
  fliepath = isfile(filepath) ? filepath : abspath(str)
  JuliaTest.eval(:(include($filepath)))
end

end # module test

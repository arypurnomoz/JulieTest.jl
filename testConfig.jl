#hiJulia config file
  
include(Pkg.dir("JulieTest/src/watch.jl"))

# Configure the watcher

watch = ["src", "test"]
interval = 0.25 # in seconds

# Configure the test reporter
reporter = "spec"

# start hiJulia
julieTest()


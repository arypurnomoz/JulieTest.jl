# User defined variable

files = ["src","test"]
interval = 0.25
quotes = readdlm(Pkg.dir("JulieTest/res/quotes.txt"), '\n')
reporter = ""

# end


# do not polute global space with function definition
function julieTest()
  global files
  global quotes
  global interval
  global reporter
  
  # we need to call runTests method from this module
  require(joinpath(Pkg.dir(),"JulieTest/src/JulieTest.jl"))
  
  lastRun = time()
  running = false
  watcher = {}
  PWD = pwd()
  currentFile = "testConfig.jl"
  
  currentFile in files || push!(files, currentFile)

  function line() 
    "\n" * "=" ^ Base.tty_size()[2] * "\n"
  end
  
  function surround(txt) 
    line() * txt * line()
  end
  
  function isTestFile(str::String) 
    ismatch(r"^([^/]+/)*[^_]+_test\.jl$",str)
  end
  
  function getQuotes() 
    quotes[floor(rand() * length(quotes))]
  end
  
  function runAllTest() 
    for file in readdir(joinpath(PWD,"test"))
      isTestFile(file) || continue
      reload(joinpath(PWD, "test", file)) 
    end
    JulieTest.runTests()
  end

  function runSingleTest(filepath::String)
    reload(filepath)
    JulieTest.runTests()
  end

  function runTestFor(filepath::String)
    # Try to find and run the test file of the given file
    if ismatch(r"src/.*\.jl", filepath)
      testpath = joinpath("test", replace(basename(filepath), r"\.jl$", "_test.jl"))
      isfile(testpath) && return runSingleTest(testpath) 
    elseif isTestFile(filepath)
      return runSingleTest(filepath)
    end
    # If no test file found for this file just run all test file
    runAllTest()
  end

  function watch(dir::String, isDir::Bool)
    # watch recursively
    if isDir
      for file in readdir(dir)
        file = joinpath(dir,file)
        isdir(file) && push!(watcher, watch(file,true))
      end
    end
    
    watch_file(dir) do filename,event,status
      (running || time() - lastRun < interval) && return
      running = true
      if isDir
        filename =  dir == "." ? filename : joinpath(dir,filename)
      else
        filename = dir
      end
      print_with_color(:green, filename, " "); println("has modified")
      try
        filename == currentFile ? restart() : runTestFor(filename)
      catch e
        print("\033[91m"); dump(e); print("\033[0m")
      end 
      running, lastRun = false, time()
    end
  end
  
  function watch(dir::String) 
    watch(dir, isdir(dir))
  end
  
  function startWatch()
    watcher = [watch(file) for file in files]
  end

  function restart()
    println("\033[91m---Reloading configuration---\033[0m")
    [close(file) for file in watcher] 
    reload(currentFile)
  end
  
  print(surround(getQuotes()))
  
  for arg in ARGS 
    if ismatch(r"--reporter=.+",arg) 
      reporter = match(r"(?<=--reporter=).+", arg).match
    end
  end
  
  JulieTest.reporter(reporter)
  
  "--single" in ARGS  && return Base.exit(runAllTest())
  "--skip-init" in ARGS || runAllTest()
  
  
  startWatch()
  while true; sleep(typemax(Int32)); end
  
end

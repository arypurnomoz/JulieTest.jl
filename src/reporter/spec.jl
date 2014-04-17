OK = '✓'
FAIL= '✖'
RESET = "\033[0m"
PAD = " " ^ 2
FAINT_COLOR = "\033[90m"
PASS_COLOR = "\033[32m"
PASS_LIGHT_COLOR = "\033[92m"
FAILED_COLOR = "\033[31m"
FAILED_LIGHT_COLOR = "\033[91m"
HOUR = 3600_000
MINUTES = 60_000
SECOND = 1000

toMilis(n) = int(n * 10e2)

function testColor()
  [println("\033[$(i)m Test_$i \033[0m") for i in 1:109]
end

function report(desc::Description)
  desc.depth == 1 && println()
  println(PAD ^ desc.depth, desc.name)
end


function summaryReport(passes,errors,elapsed)
  println()
  println(PASS_LIGHT_COLOR, PAD, length(passes), " passing ",FAINT_COLOR, "(", showTime(elapsed), ")")
  length(errors) == 0 || println(FAILED_LIGHT_COLOR, PAD, length(errors), " failing")
  println(RESET)
end

function showTime(n)
  if n > HOUR
    string(n/HOUR)[1:3] * "h"
  elseif n > MINUTES
    string(n/MINUTES)[1:3] * "m"
  elseif n > SECOND
    string(n/SECOND)[1:3] * "s"
  else
    string(n) * "ms"
  end
end

function colorTime(elapsed::Int)
  if elapsed != 0
    color = elapsed > 500 ? 91 : (elapsed > 100 ? 93 : 90)
    " \e[$(color)m($(showTime(elapsed)))$RESET"
  else
    ""
  end
end

function passReport(test::Test, elapsed::Int)
  println(PAD ^ test.desc.depth,PAD, PASS_LIGHT_COLOR, OK, "\033[90m ", test.name, colorTime(elapsed))
end

function failedReport(err::DescriptionError)
  err.desc.depth == 1 && println()
  print(PAD ^ err.desc.depth,FAILED_COLOR, FAIL,
    " PANIC! Got an error while called describe: ",err.desc.name
  )
  print(RESET,'\n')
end

function failedReport(err::Error)
  print(PAD ^ err.test.desc.depth,PAD,FAILED_COLOR, FAIL," ",err.test.name)
  print(RESET,'\n')
end

function fullFailedReport(errors)
  for i in 1:length(errors)
    err = errors[i]
    println(PAD, i, ") ", err.test.desc.name, " - ", err.test.name, ":", FAILED_COLOR, PAD)
    dump(err.err)
    #=for i in 1:2=#
    #=  println(PAD ^ 2,err.trace[i])=#
    #=end=#
    println(RESET)
  end
end

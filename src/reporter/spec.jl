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
DESCRIPTION_ERROR_MESSAGE = "PANIC! Got an error while called describe"

toMilis(n) = int(n * 10e2)

function testColor()
  [println("\033[$(i)m Test_$i \033[0m") for i in 1:109]
end

function report(desc::Description)
  desc.depth == 1 && println()
  println(PAD ^ desc.depth, desc.name)
end


function summaryReport(passes::Array{Test,1},errors::Array{Union(Error,DescriptionError),1},elapsed)
  println()
  println(PASS_LIGHT_COLOR, PAD, length(passes), " passing ",FAINT_COLOR, "(", showTime(elapsed), ")")
  length(errors) == 0 || println(FAILED_LIGHT_COLOR, PAD, length(errors), " failing")
  println(RESET)
  length(errors) == 0  || fullFailedReport(errors)
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
  println(PAD ^ test.desc.depth,PAD, PASS_LIGHT_COLOR, OK, "\033[90m ", test.name, colorTime(elapsed), RESET)
end

function failedReport(err::DescriptionError)
  err.desc.depth == 1 && println()
  println(
    PAD ^ err.desc.depth,FAILED_COLOR, FAIL, " ",
    DESCRIPTION_ERROR_MESSAGE, " - ", err.desc.name,
    RESET
  )
end

function failedReport(err::Error)
  print(PAD ^ err.test.desc.depth,PAD,FAILED_COLOR, FAIL," ",err.test.name)
  print(RESET,'\n')
end


function fullFailedReport(errors::Array{Union(Error,DescriptionError),1})
  for i in 1:length(errors)
    err = errors[i]
    print(PAD, i, ") ")
    if isa(err, DescriptionError)
      print(DESCRIPTION_ERROR_MESSAGE, " - ", err.desc.name)
    else
      print(err.test.desc.name, " - ", err.test.name)
    end
    println(":", FAILED_COLOR)
    dump(err.err)
    println(RESET)
  end
end

RESET = "\033[0m"
FAINT_COLOR = "\033[90m"
PASS_COLOR = "\033[32m"
PASS_LIGHT_COLOR = "\033[92m"
FAILED_COLOR = "\033[31m"
FAILED_LIGHT_COLOR = "\033[91m"

DESCRIPTION_ERROR_MESSAGE = "PANIC! Got an error while called describe"

HOUR = 3600_000
MINUTES = 60_000
SECOND = 1000

toMilis(n) = int(n * 10e2)

function report(desc::Description)
end

function summaryReport(passes::Array{Test,1},errors::Array{Union(Error,DescriptionError),1},elapsed)
  println('\n',PASS_LIGHT_COLOR, length(passes), " passing ",FAINT_COLOR, "(", showTime(elapsed), ")")
  length(errors) == 0 || println(FAILED_LIGHT_COLOR, length(errors), " failing")
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
  print(PASS_COLOR,'.', RESET)
end

function failedReport(err::DescriptionError)
  println(FAILED_COLOR, 
    "\nPANIC! Got an error while called describe: ",err.desc.name, RESET
  )
end

function failedReport(err::Error)
  print(FAILED_COLOR,'.',RESET)
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

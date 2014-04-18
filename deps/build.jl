home = homedir()

for rc in [".bashrc", ".zshrc"]
  rc = joinpath(home, rc)
  if isfile(rc) && !ismatch(r"alias julie",readall(open(rc)))
    open(rc, "a") do file
      write(file, "\nalias julie=$(Pkg.dir("JulieTest/julie"))")
      try run(`source $rc`) end
    end
  end
end

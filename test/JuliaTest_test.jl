module JulieTest_test

using JulieTest

noob() = Nothing

describe("@is") do
  it("basic") do
    @is 1 => 1
  end
  
  it("expression on left side") do
    @is 1 + 1 => 2
  end
  
  it("variable on the left side") do
    x = 1
    @is x => 1
  end
  it("variable on the left and right side") do
    y = x = 1
    @is x => y
  end
  it("expression on the left, variable on the right side") do
    x = 1
    y = 2
    @is x + x => y
  end

  it("expression and variable on the left and right side") do
    x,y = 3,2
    @is x + 2 => y + 3
  end

  it("singular") do
    x = 2
    @is x == x
  end

  it("with one right side condition") do
    x,y = 2, 3
    @is x + x => above y
  end

  it("with multiple right side condition") do
    x,y = 2, 3
    @is x + x => truthy not not above y
  end

  it("with one right side without parameter") do
    x = []
    @is x => empty
  end
  
  
  describe("recursive describe") do
    it(noob, "in recursive")
    describe("going deeper") do
      it(noob, "it's dark here")
    end
  end

end

describe("condition function") do
  it("least") do
    x = 2
    @is x => least 2
    @is x => atleast 2
    @is x => atLeast 2
  end
  
  it("not") do
    @is 1 => not 2
    
  it("double not") do
    @is 1 => not not 1
  end
  end
  
  it("built-in isa") do
    @is 1 => isa Number
  end
end

end # module testTest

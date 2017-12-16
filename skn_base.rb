# ./skn_base.rb

require "roda"

class SknBase < Roda

  route do |r|
    r.root do
      "Hello Puma!"
    end
  end

end

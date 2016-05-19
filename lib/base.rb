module Philter
  module Base
    private
    def get_operator exp
      regexp = "(?:<=?|>=?|!=|==|===|=~)"
      if exp =~ /#{regexp}/
        exp.match(/#{regexp}/).to_s
      else
        nil
      end
    end
  end
end

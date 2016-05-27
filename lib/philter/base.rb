# Philter methods
module Philter
  # It contains generic methods
  module Base
    private

    # Show tips on usage
    def philter_help
      <<-HELP.gsub(/^      /, '')
      *************************************************************************
      Philter version #{Philter.version}
      [].philter 'search', {options}
      Examples:
      [1,2,3].philter 1 => [1]
      [1,2,3].philter [2,3] => [2, 3]
      [{id: 1, name: 'Mark'},{id: 2, name: 'Bill'}].philter id: 1
      Articles.philter id: 1
      People.philter   name: 'Mario'
      People.philter   email: /\A.+@gmail/
      Use option get: to select an attribute
      People.philter   {id: 1}, get: :surname
      Use option debug: to watch the selection
      Articles.philter {id: 1}, debug: true
      *************************************************************************
      HELP
    end
  end
end

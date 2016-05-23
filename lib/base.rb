module Philter
  module Base
    private
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

    def get_operator exp
      return unless exp.is_a? String
      regexp = "(?:<=?|>=?|!=|==|===|=~)"
      if exp =~ /#{regexp}/
        exp.match(/#{regexp}/).to_s
      else
        nil
      end
    end

    def phil_evaluate item, label, value, evaluation, options={}
      options = {
          operator:     '==',
          debug:        false
      }.merge(options)
      operator    = get_operator value
      value       = operator ? value.gsub(operator,'').to_i : value
      operator  ||= options[:operator]
      item_to_s   = operator == '=~' ? '.to_s' : ''
      case evaluation
        when :method
          print " #{item.class.name}.#{label} #{operator} value "           if options[:debug]
          print "| #{item.send(label)} #{operator} #{value}"                if options[:debug]
          eval("item.send(label) #{operator} value")
        when :hash
          print " #{item.class.name}[:#{label}] #{operator} value"                                   if options[:debug]
          print "| #{item[label]} #{operator} #{value} "                     if options[:debug]
          eval("item[label]#{item_to_s} #{operator} value")
        when :simple
          print " item #{operator} value"                                   if options[:debug]
          print " | #{item} #{operator} #{value}"                         if options[:debug]
          eval("item#{item_to_s} #{operator} value")
        else
          raise "phil_evaluate: evaluation #{evaluation ? "#{evaluation} not valid!" : "blank!"}"
      end
    end
  end
end

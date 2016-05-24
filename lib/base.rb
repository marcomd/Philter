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

    # Search params respond to each method
    def search_from_list search, item, options={}
      selected_or, selected_and = nil, nil
      search.each do |value|
        # Every item must match with search options to be selected
        puts " a. search: #{value.class.name} #{value}"                    if options[:debug]
        if value.is_a?(Array)
          # Example search: {code: 1} or search: {code: [1,2]}
          label, values = value
          values = [values] unless values.is_a?(Array)
          values.each do |value|
            selected = nil
            if item.respond_to?(label)
              print "  1.x "                                               if options[:debug]
              if value.is_a?(Regexp)
                print " .1 "                                               if options[:debug]
                selected = phil_evaluate item, label, value, :method, options.merge(operator: '=~')
              else
                # search: {id: 2}
                # search: {id: '<3'} or any other operator
                print " .2 " if options[:debug]
                selected = phil_evaluate item, label, value, :method, options.merge(operator: '==')
              end
            elsif item.respond_to? '[]'
              print "  1.y label: #{label.class.name}"                     if options[:debug]
              if value.is_a?(Regexp)
                # search: {email: /@gmail/}
                print " .1 "                                               if options[:debug]
                selected = phil_evaluate item, label, value, :hash, options.merge(operator: '=~')
              elsif item.is_a?(Hash) && !label.is_a?(Fixnum)
                # search: {id: 1} or {'name' => 'Mark'}
                # search: {id: '<3'} or any other operator
                print " .2 " if options[:debug]
                selected = phil_evaluate item, label, value, :hash, options.merge(operator: '==')
              else
                print " .3 no action for #{value} !!!"                     if options[:debug]
              end
            else
              print "  1.z selector not present !!!"                       if options[:debug]
            end
            puts "  #{'=> X' if selected}"                                 if options[:debug]
            selected_or   = true      if !selected_or && selected
            selected_and  = selected  if selected_and
          end
        elsif value.is_a?(Regexp)
          # search: {email: /@gmail/}
          print "   2. "                                                   if options[:debug]
          selected = phil_evaluate item, nil, value, :simple, options.merge(operator: '=~')
          puts "  #{'=> X' if selected}"                                   if options[:debug]
        else
          # Example search: [3] or search: [3, 4]
          print "   3. "                                                   if options[:debug]
          selected = phil_evaluate item, nil, value, :simple, options.merge(operator: '==')
          puts "  #{'=> X' if selected}"                                   if options[:debug]
        end
        selected_or   = true      if !selected_or && selected
        selected_and  = selected  if selected_and
      end
      selected_or
    end
  end
end

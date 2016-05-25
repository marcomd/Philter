module Philter
  module Base
    private

    def phil_search_with_operator search, options={}
      results = []
      self.each do |item|
        puts "item #{item.class.name} #{item}"                               if options[:debug]
        selected = phil_evaluate item, search, options
        puts " #{'=> X' if selected}"                                        if options[:debug]
        results << item if selected
      end
      results
    end

    def phil_search_by_array search, options={}
      puts "search #{search} (#{search.class.name}) "                        if options[:debug]
      search_same_class = false
      search.inject{|prev, cur| search_same_class=prev.class == cur.class; cur }
      if search_same_class
        self.select do |item|
          if search.first.class.name == 'Class'
            search.include? item.class
          else
            search.include? item
          end
        end
      else
        # Check every search item
        search.each do |search_value|
          self.select do |item|
            if search_value.class.name == 'Class'
              search_value == item.class
            else
              search_value == item
            end
          end
        end
      end
    end

    def phil_search_by_attributes search, options={}
      results = []
      self.each do |item|
        selected = nil
        # Evaluate each array's item
        puts "item #{item} (#{item.class.name}) "                             if options[:debug]
        case item.class.name
          when "Array"
            print "  a. discarded"                                            if options[:debug]
          when "Hash"
            print "  h. "                                                     if options[:debug]
            selected = phil_apply_attributes item, search, options
          when phil_base_objects
            print "  b. discarded"                                            if options[:debug]
          else
            print "  o. "                                                     if options[:debug]
            selected = phil_apply_attributes item, search, options
        end
        # puts " #{'=> X' if selected}"                                         if options[:debug]
        if selected
          results <<
              if options[:get]
                if item.respond_to? options[:get]
                  item.send options[:get]
                elsif item.respond_to? '[]'
                  item[options[:get]]
                end
              else
                item
              end
        end
      end
      results
    end

    def phil_apply_attributes item, search, options={}
      selected_or, selected_and = nil, true
      search.each do |key, search_value|
        # Every item must match with search options to be selected
        puts " search: #{key}: #{search_value} (#{search_value.class.name})"                if options[:debug]
        case search_value.class.name
          when 'Regexp'
            # search: {email: /@gmail/}
            print "   .1 "                                                                  if options[:debug]
            selected = phil_evaluate item_value(item, key, options), search_value, options.merge(operator: '=~')
          when 'Class'
            # search: {code: String} or {code: Fixnum}
            print "   .2 item.class == value | #{item.class} == #{search_value}"            if options[:debug]
            selected = item_value(item, key, options).class == search_value
          when 'Array'
            # search: {id: [1,2]}
            print "   .3 "                                                                  if options[:debug]
            selected = search_value.include? item_value(item, key, options)
          else
            # search: {id: 2} or {id: '<3'} or any other operator
            print "   .4 "                                                                  if options[:debug]
            selected = phil_evaluate item_value(item, key, options), search_value, options.merge(operator: '==')
        end
        puts "  #{'=> x' if selected}"                                                      if options[:debug]
        selected_or   = true      if !selected_or && selected
        selected_and  = selected  if selected_and
      end

      if options[:or]
        puts " #{'=> X (Or)' if selected_or}"                                               if options[:debug]
        selected_or
      else
        puts " #{'=> X (And)' if selected_and}"                                             if options[:debug]
        selected_and
      end
    end

    def item_value item, label, options={}
      case item.class.name
        when "Hash"   then
          print " v1 item[#{label}] "                                                       if options[:debug]
          item[label]
        when "Fixnum", "Float", "Bignum", "Symbol", "String"
          print " v2 #{item.class.name} "                                                   if options[:debug]
          if options[:everywhere]
            print "#{item} "                                                                if options[:debug]
            item
          else
            print "- "                                                                      if options[:debug]
            nil
          end
        else
          print " v3 item.#{label} "                                                        if options[:debug]
          item.send(label) if item.respond_to? label
      end
    end

    def phil_evaluate item, value, options={}
      options = {
          operator:     '==',
          debug:        false
      }.merge(options)
      operator    = phil_get_operator value
      value       = operator ? value.gsub(operator,'').to_i : value
      operator  ||= options[:operator]
      print " item #{operator} value"                            if options[:debug]
      print " | #{item} #{operator} #{value}"                    if options[:debug]
      case operator
        when '=~'   then item.to_s  =~  value
        when '=='   then item       ==  value
        when '==='  then item       === value
        when '>'    then item       >   value
        when '<'    then item       <   value
        when '>='   then item       >=  value
        when '<='   then item       <=  value
        when '!='   then item       !=  value
      end
    end

    def phil_get_operator exp
      return unless exp.is_a? String
      regexp = "(?:<=?|>=?|!=|==|===|=~)"
      if exp =~ /#{regexp}/
        exp.match(/#{regexp}/).to_s
      else
        nil
      end
    end

    def phil_base_objects
      return "Fixnum", "Float", "Bignum", "Symbol", "String"
    end

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

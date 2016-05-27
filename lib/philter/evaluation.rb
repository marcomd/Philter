# Philter methods
module Philter
  # It contains all the methods for selecting the items
  module Evaluation
    private

    # Evaluate search attributes to any item
    # in:   item, search, options{debug:nil}
    # out:  true/false (if the item has been selected)
    def phil_eval_attributes(item, search, options = {})
      selected_or  = nil
      selected_and = true
      search.each do |key, search_value|
        # Every item must match with search options to be selected
        puts "   search: #{key}: #{search_value} " \
             "(#{search_value.class.name})" if options[:debug]
        case search_value.class.name
        when 'Regexp'
          # search: {email: /@gmail/}
          print '   .1 ' if options[:debug]
          selected = phil_evaluate item_value(item, key, options),
                                   search_value,
                                   options.merge(operator: '=~')
        when 'Class'
          # search: {code: String} or {code: Fixnum}
          print '   .2 item.class == value | ' \
                "#{item.class} == #{search_value}" if options[:debug]
          selected = item_value(item, key, options).class == search_value
        when 'Array'
          # search: {id: [1,2]}
          print '   .3 ' if options[:debug]
          selected = search_value.include? item_value(item, key, options)
        else
          # search: {id: 2} or {id: '<3'} or any other operator
          print '   .4 ' if options[:debug]
          selected = phil_evaluate item_value(item, key, options),
                                   search_value,
                                   options.merge(operator: '==')
        end
        puts "  #{selected && '=> x'}" if options[:debug]
        selected_or   = true      if !selected_or && selected
        selected_and  = selected  if selected_and
      end

      if options[:or]
        puts " #{selected_or && '- SELECTED - (Or)'}" if options[:debug]
        selected_or
      else
        puts " #{selected_and && '- SELECTED - (And)'}" if options[:debug]
        selected_and
      end
    end

    # Provide the item's value
    # in:   item, attribute, options{debug:nil}
    # out:  the item's value
    def item_value(item, attribute, options = {})
      case item.class.name
      when 'Hash' then
        print " item[#{attribute}] = #{item[attribute]} " if options[:debug]
        item[attribute]
      when 'Fixnum', 'Float', 'Bignum', 'Symbol', 'String'
        print " #{item.class.name} " if options[:debug]
        print "#{item} " if options[:debug]
        item
      else
        print " item.#{attribute} " if options[:debug]
        if item.respond_to?(attribute)
          print "= #{item.send(attribute)} " if options[:debug]
          item.send(attribute)
        end
      end
    end

    # Evaluate a condition: item -operator- value
    # in:   item, value, options{operator:'==',debug:false}
    # out:  true/false
    def phil_evaluate(item, value, options = {})
      options = { operator: '==',
                  debug:    false }.merge(options)
      value, operator = phil_get_operator_value_cleaned value
      operator ||= options[:operator]
      print " item #{operator} value" if options[:debug]
      print " | #{item} #{operator} #{value}" if options[:debug]
      case operator
      when '=~' then item.to_s =~ value
      when '===' then item === value
      when '==' then item == value
      when '>=' then item >= value
      when '<=' then item <= value
      when '!=' then item != value
      when '>' then item > value
      when '<' then item < value
      end
    end

    # Search an operator in value
    # in:   value
    # out:  value without operator, operator
    def phil_get_operator_value_cleaned(value)
      operator  = phil_get_operator value
      value     = value.gsub(operator, '').to_i if operator
      [value, operator]
    end

    # Search an operator by regexp (?:<=?|>=?|!=|==|===|=~)
    # in:   value
    # out:  operator
    def phil_get_operator(str)
      return unless str.is_a?(String)
      regexp = '(?:<=?|>=?|!=|==|===|=~)'
      str.match(/#{regexp}/).to_s if str =~ /#{regexp}/
    end
  end
end

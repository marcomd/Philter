# Philter methods
module Philter
  # It contains methods to select array's items
  module Search
    private

    # Called when search is a string with an operator
    # in:   search, options{debug:nil}
    # out:  array of selected items
    def phil_search_with_operator(items, search, options = {})
      puts " #{search} with operator" if options[:debug]
      results = []
      items.each do |item|
        puts " item #{item.class.name} #{item}" if options[:debug]
        selected = phil_evaluate item, search, options
        puts " #{selected && '=> x'}" if options[:debug]
        results << item if selected
      end
      results
    end

    # Called when search is an array
    # in:   search, options{debug:nil}
    # out:  array of selected items
    def phil_search_by_array(items, search, options = {})
      puts " #{search}" if options[:debug]
      search_same_class = false
      # Check if search's objects are all the same class
      search.inject do |prev, cur|
        search_same_class = prev.class == cur.class
        cur
      end
      if search_same_class
        items.select do |item|
          if search.first.class.name == 'Class'
            selected = search.include?(item.class)
            puts "  item: #{item} #{selected && '=> x'}" if options[:debug]
            selected
          else
            selected = search.include?(item)
            puts "  item: #{item} #{selected && '=> x'}" if options[:debug]
            selected
          end
        end
      else
        # If there are many classes in search, check every search item
        search.each do |search_value|
          items.select do |item|
            if search_value.class.name == 'Class'
              selected = search_value == item.class
              puts "  item: #{item} #{selected && '=> x'}" if options[:debug]
              selected
            else
              selected = search_value == item
              puts "  item: #{item} #{selected && '=> x'}" if options[:debug]
              selected
            end
          end
        end
      end
    end

    # Search the search attribute in the item
    # in:   search, options{debug:nil}
    # out:  array of selected items
    def phil_search_by_attributes(items, search, options = {})
      puts " #{search}" if options[:debug]
      results = []
      items.each do |item|
        selected = nil
        # Evaluate each array's item
        puts if options[:debug]
        puts " item #{item} (#{item.class.name}) " if options[:debug]
        case item.class.name
        when 'Array'
          puts '  item is an array => discarded' if options[:debug]
        when 'Hash'
          puts '  evaluating hash ' if options[:debug]
          selected = phil_eval_attributes item, search, options
        when 'Fixnum', 'Float', 'Bignum', 'Symbol', 'String'
          print "  evaluating #{item.class.name} " if options[:debug]
          if options[:everywhere]
            print ' => everywhere' if options[:debug]
            selected = phil_eval_attributes item, search, options
          else
            print ' => discarded' if options[:debug]
          end
        else
          puts "  evaluating #{item.class.name}'s attributes" if options[:debug]
          selected = phil_eval_attributes item, search, options
        end

        next unless selected
        results <<
          if options[:get] && item.respond_to?(options[:get])
            item.send options[:get]
          elsif options[:get] && item.respond_to?('[]')
            item[options[:get]]
          else
            item
          end
      end
      results
    end
  end
end

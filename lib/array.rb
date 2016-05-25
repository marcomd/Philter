class Array
  include Philter::Base
  def philter search=nil, options={}, &block
    options = {
        get:          nil,
        debug:        false
    }.merge(options)
    unless search
      puts philter_help if options[:debug]
      raise "Specify search parameter!"
    end

    apply_block = true
    results =
    case search.class.name
      when "Hash"
        print " h. "                                                      if options[:debug]
        phil_search_by_attributes search, options
      when "String"
        print " s. "                                                      if options[:debug]
        operator = phil_get_operator search
        operator ? phil_search_with_operator(search, operator: operator) : self.grep(search)
      when "Array"
        print " a. "                                                      if options[:debug]
        phil_search_by_array search, options
      else
        puts " g. #{search}"                                              if options[:debug]
        apply_block = false
        self.grep(search, &block)
    end

    puts "------------------"                                                                     if options[:debug]
    puts " #{results ? results.size : 'No'} item#{results && results.size == 1 ? '' : 's'} found" if options[:debug]
    if block_given? && apply_block
      results.map{|item| block.call(item)}
    else
      results
    end
  end
end

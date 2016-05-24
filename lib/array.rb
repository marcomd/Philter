class Array
  include Philter::Base
  def philter search=nil, options={}
    options = {
        get:          nil,
        debug:        false
    }.merge(options)
    unless search
      puts philter_help if options[:debug]
      raise "Specify search parameter!"
    end
    results = []
    self.each do |item|
      puts "item #{item.class.name} #{item}"                               if options[:debug]
      if search.respond_to? :each
        # search: {} or []
        selected = search_from_list search, item, options
      elsif search.is_a?(Regexp)
        # Search has one item
        # search: 3 or search: 'a'
        print " b.  "                                                      if options[:debug]
        selected = phil_evaluate item, nil, search, :simple, options.merge(operator: '=~')
        puts "  #{'=> X' if selected}"                                     if options[:debug]
      else
        # Search has one item
        # search: 3 or search: 'a'
        # search: '<3' or any other operator
        print " c.  "                                                      if options[:debug]
        selected = phil_evaluate item, nil, search, :simple, options.merge(operator: '==')
        puts "  #{'=> X' if selected}"                                     if options[:debug]
      end
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
    puts "------------------"                                                                     if options[:debug]
    puts " #{results ? results.size : 'No'} item#{results && results.size == 1 ? '' : 's'} found" if options[:debug]
    results
  end
end

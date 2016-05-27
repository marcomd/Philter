###################################
# Philter with passion
###################################
class Array
  include Philter::Base
  include Philter::Search
  include Philter::Evaluation

  # Have yourself indulging in the pleasure of philtering
  def philter(search = nil, options = {}, &block)
    options = { get:   nil,
                debug: false }.merge(options)
    unless search
      puts philter_help if options[:debug]
      raise 'Specify search parameter!'
    end
    puts if options[:debug]
    puts "#{'-' * 15} Start debugging philter #{Philter.version} #{'-' * 15}" if options[:debug]
    items = self
    apply_block = true
    results =
      case search.class.name
      when 'Hash'
        print ' Search by Hash:' if options[:debug]
        phil_search_by_attributes(items, search, options)
      when 'String'
        print ' Search by String:' if options[:debug]
        operator = phil_get_operator(search)
        if operator
          phil_search_with_operator(items, search, options)
        else
          puts " #{search} with grep" if options[:debug]
          items.grep(search)
        end
      when 'Array'
        print ' Search by Array:' if options[:debug]
        phil_search_by_array(items, search, options)
      else
        puts " Search with grep: #{search}" if options[:debug]
        apply_block = false
        items.grep(search, &block)
      end

    puts "#{'-' * 15} End debugging philter #{Philter.version} #{'-' * 15}" if options[:debug]
    puts " #{results.size} item(s) found" if options[:debug]
    if block_given? && apply_block
      results.map { |item| yield(item) }
    else
      results
    end
  end
end

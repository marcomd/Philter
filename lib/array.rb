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
       puts "item #{item.class.name} #{item}"                                 if options[:debug]
       h_selected = {all: nil, at_least_one: nil}
       if search.respond_to? :each
         # search: {} or []
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
                   print " .3 no action for #{value} !!!"                       if options[:debug]
                 end
               else
                 print "  1.z selector not present !!!"                         if options[:debug]
               end
               puts "  #{'=> X' if selected}"                                   if options[:debug]
               h_selected[:at_least_one] ||= selected
             end
           elsif value.is_a?(Regexp)
             # search: {email: /@gmail/}
             print "   2. "                                                   if options[:debug]
             selected = phil_evaluate item, nil, value, :simple, options.merge(operator: '=~')
             puts "  #{'=> X' if selected}"                                 if options[:debug]
             h_selected[:at_least_one] ||= selected
           else
             # Example search: [3] or search: [3, 4]
             print "   3. "                                                 if options[:debug]
             selected = phil_evaluate item, nil, value, :simple, options.merge(operator: '==')
             puts "  #{'=> X' if selected}"                                 if options[:debug]
             h_selected[:at_least_one] ||= selected
           end
         end
       elsif search.is_a?(Regexp)
         # Search has one item
         # search: 3 or search: 'a'
         print " b.  "                                                      if options[:debug]
         selected = phil_evaluate item, nil, search, :simple, options.merge(operator: '=~')
         puts "  #{'=> X' if selected}"                                     if options[:debug]
         h_selected[:at_least_one] ||= selected
       else
         # Search has one item
         # search: 3 or search: 'a'
         # search: '<3' or any other operator
         print " c.  "                                                      if options[:debug]
         selected = phil_evaluate item, nil, search, :simple, options.merge(operator: '==')
         puts "  #{'=> X' if selected}"                                     if options[:debug]
         h_selected[:at_least_one] ||= selected
       end
       if h_selected[:at_least_one] || h_selected[:all]
          tmp_result = if options[:get]
                         item.respond_to?(options[:get]) ? item.send(options[:get]) : item[options[:get]]
                       else
                         item
                       end
          results << tmp_result
        end
    end
    puts "------------------"                                               if options[:debug]
    puts " #{results ? results.size : 'No'} item#{results && results.size == 1 ? '' : 's'} found" if options[:debug]
    results
  end
end

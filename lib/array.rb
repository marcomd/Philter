class Array
  def philter search=nil, options={}
    options = {
        get:          nil,
        debug:        false
    }.merge(options)
    help = <<-HELP.gsub(/^      /, '')
      *************************************************************************
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
    unless search
       puts help if options[:debug]
       raise "Specify search parameter!"
    end

    results = []
    self.each do |item|
       puts "item #{item.class.name} #{item}"                               if options[:debug]
       condition = {all: nil, at_least_one: nil}
       if search.respond_to? :each
         # search: {} or []
         search.each do |value|
           # Every item must match with search options to be selected
           puts " a. search: #{value.class.name} #{value}"                  if options[:debug]
           if value.is_a?(Array)
             # Example search: {code: 1} or search: {code: [1,2]}
             label, values = value
             values = [values] unless values.is_a?(Array)
             values.each do |value|
               selected = nil
               if item.respond_to?(label)
                 print "  1.x " if options[:debug]
                 if value.is_a?(Regexp)
                   print " .1 #{item.class.name}.#{label} =~ value "        if options[:debug]
                   print "| #{item.send(label)} =~ #{value}"                if options[:debug]
                   selected = item.send(label) =~ value
                 else
                   print " .2 #{item.class.name}.#{label} == value "        if options[:debug]
                   print "| #{item.send(label)} == #{value}"                if options[:debug]
                   selected = item.send(label) == value
                 end
               elsif item.respond_to? '[]'
                 print "  1.y label: #{label.class.name}"                   if options[:debug]
                 if value.is_a?(Regexp)
                   # search: {email: /@gmail/}
                   print " .1 value === item "                              if options[:debug]
                   print "| #{value} === '#{item[label]}'"                  if options[:debug]
                   selected = value === item[label].to_s
                 elsif item.is_a?(Hash) && !label.is_a?(Fixnum)
                   # search: {id: 1} or {'name' => 'Mark'}
                   print " .2 #{item.class.name}[:#{label}] == value "      if options[:debug]
                   print "| #{item[label]} == #{value}"                     if options[:debug]
                   selected = item[label] == value
                 else
                   print " .3 no action for #{value} !!!"                   if options[:debug]
                 end
               else
                 print "  1.z selector not present !!!"                     if options[:debug]
               end
               puts "  #{'=> X' if selected}"                               if options[:debug]
               condition[:at_least_one] ||= selected
             end
           elsif value.is_a?(Regexp)
             # search: {email: /@gmail/}
             print "   2. value === item "                                  if options[:debug]
             print " | #{value} === '#{item}'"                              if options[:debug]
             selected = value === item.to_s
             puts "  #{'=> X' if selected}"                                 if options[:debug]
             condition[:at_least_one] ||= selected
           else
             # Example search: [3] or search: [3, 4]
             print "   3. item == value "                                   if options[:debug]
             print "| #{item} == #{value}"                                  if options[:debug]
             selected = item == value
             puts "  #{'=> X' if selected}"                                 if options[:debug]
             condition[:at_least_one] ||= selected
           end
         end
       elsif search.is_a?(Regexp)
         # Search has one item
         # search: 3 or search: 'a'
         print " b. search === item "                                       if options[:debug]
         print " | #{search} === '#{item}'"                                 if options[:debug]
         selected = search === item.to_s
         puts "  #{'=> X' if selected}"                                     if options[:debug]
         condition[:at_least_one] ||= selected
       else
         # Search has one item
         # search: 3 or search: 'a'
         print " c. item == search "                                        if options[:debug]
         print "| #{item} == #{search}"                                     if options[:debug]
         selected = item == search
         puts "  #{'=> X' if selected}"                                     if options[:debug]
         condition[:at_least_one] ||= selected
       end
       if condition[:at_least_one] || condition[:all]
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

  def phelect arg_fields
    fields = arg_fields.split(',').flatten if arg_fields.respond_to?('split')
    self.map do |item|
      record = {}
      fields.each do |field|
        if item.respond_to?(field)
          record[field.to_sym] = item.send field
        elsif item.respond_to?'[]'
          record[field.to_sym] = (item[field] || item[field.to_sym])
        else
          # How do i get the data ?
        end
      end
    end
  end
end

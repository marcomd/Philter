![](/assets/logo.png)

## It helps your life and without weighing too much on global warming
### Sometimes it help you to filter some arrays

[![Version     ](https://badge.fury.io/rb/philter.svg)                        ](https://rubygems.org/gems/philter)
[![Travis CI   ](http://img.shields.io/travis/marcomd/Philter/master.svg)     ](https://travis-ci.org/marcomd/Philter)
[![Quality     ](http://img.shields.io/codeclimate/github/marcomd/Philter.svg)](https://codeclimate.com/github/marcomd/Philter)

Filter any kind of array with the power of ruby, with ease and :smile:

It's short, dynamic and readable. Its trace is a usefull tool for teachers.

The performance is inversely proportional to the comfort although efficiency is improved in the latest versions. See the section below.

```ruby
require 'philter'

# You can use everything to filter
# ...single value
[1,2,3].philter 1
=> [1]

# ...array of values
[1,2,3].philter [2,3]
=> [2,3]

# ...operators
[1,2,3].philter '<= 2'
=> [1,2]

[1,2,3].philter '!= 2'
=> [1,3]

# ...range
[1,2,3,4,5].philter 2..4
=> [2, 3, 4]

%w[red green blue].philter 'red'
=> ["red"]

%w[red green blue].philter %w(red blue)
=> ["red", "blue"]

# You can pass a block
[1,2,3].philter([1,2]) { |e| e*2 }
=> [2, 4]
```

Things get more interesting with array of hashes or objects :yum:

```ruby
people = [{ id: 1, name: 'Mark',  email: 'mark@gmail.com'  },
          { id: 2, name: 'Larry', email: 'larry@gmail.com' },
          { id: 3, name: 'Bill',  email: 'bill@live.com'   }
]

people.philter id: 1
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}]

people.philter id: [1,3]
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}, {:id=>3, :name=>"Bill", :email=>"bill@live.com"}]

people.philter id: '>2'
=> [{:id=>3, :name=>"Bill", :email=>"bill@live.com"}]

# Regular expression
people.philter email: /@gmail/
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}, {:id=>2, :name=>"Larry", :email=>"larry@gmail.com"}]

# Select attributes
people.philter({ email: /@gmail/ }, get: :name)
=> ["Mark", "Larry"]

# Philter with more attributes -and-
people.philter name: /M.+/, email: /@gmail/
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}]

# Philter with more attributes -or-
people.philter({ name: /M.+/, email: /@live/ }, or: true)
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}, {:id=>3, :name=>"Bill", :email=>"bill@live.com"}]
```

To me the power! :godmode:

```ruby
# Select and update attributes
regexp = /gmail/
people.philter(email: regexp) { |e| "#{e[:name]} use #{e[:email].match(regexp)}!"}
=> ["Mark use gmail!", "Larry use gmail!"]

# Add attributes
people.philter(email: /@gmail/) do |e|
  e[:filtered] = true
  e
end
=> :try_yourself
```

Get the trace with the option `debug: true`

```ruby
[1,2,3].philter '<= 2', debug: true
--------------- Start debugging philter 1.1.0 -------------
 Search by String: <= 2 with operator
 item Fixnum 1
 item <= value | 1 <= 2 => x
 item Fixnum 2
 item <= value | 2 <= 2 => x
 item Fixnum 3
 item <= value | 3 <= 2
--------------- End debugging philter 1.1.0 ---------------
 2 item(s) found
=> [1, 2]

people.philter({ name: 'Mark', email: /\A.+gmail/ }, debug: true)
--------------- Start debugging philter 1.1.0 ---------------
 Search by Hash:

 item {:id=>1, :name=>"Mark", :email=>"mark@gmail.com"} (Hash)
  evaluating with hash
   search: name: Mark (String)
   .4  v1 item[name]  item == value | Mark == Mark  => x
   search: email: (?-mix:\A.+gmail) (Regexp)
   .1  v1 item[email]  item =~ value | mark@gmail.com =~ (?-mix:\A.+gmail)  => x

 - SELECTED - (And)

 item {:id=>2, :name=>"Bill", :email=>"bill@live.com"} (Hash)
  evaluating with hash
   search: name: Mark (String)
   .4  v1 item[name]  item == value | Bill == Mark
   search: email: (?-mix:\A.+gmail) (Regexp)
   .1  v1 item[email]  item =~ value | bill@live.com =~ (?-mix:\A.+gmail)

 item {:id=>3, :name=>"Larry", :email=>"larry@gmail.com"} (Hash)
  evaluating with hash
   search: name: Mark (String)
   .4  v1 item[name]  item == value | Larry == Mark
   search: email: (?-mix:\A.+gmail) (Regexp)
   .1  v1 item[email]  item =~ value | larry@gmail.com =~ (?-mix:\A.+gmail)  => x

--------------- End debugging philter 1.1.0 ---------------
 1 item(s) found
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}]
```

### Rails

Rails return relation objects that must be turned to array

```ruby
cities = City.all.to_a
  City Load (1.0ms)  SELECT "cities".* FROM "cities"
=> ... [cut]

cities.philter id: 1
=> [#<City id: 1, name: "Milano", code: "MI", region: "Lombardia", created_at: "2016-05-10 09:07:22", updated_at: "2016-05-10 09:07:22">]

cities.philter code: 'PA'
=> [#<City id: 4, name: "Palermo", code: "PA", region: "Sicilia", created_at: "2016-05-10 09:08:13", updated_at: "2016-05-10 09:08:13">]

# Pass a block to select, update or change the result
cities.philter(region: /\Alomb/i) { |city| "#{city.name}-#{city.code}" }
=> ["Milano-MI", "Lecco-LC", "Pavia-PV", "Piacenza-PC", ... [cut]

```

## Performance

Since version `1.0.0` performance are greatly improved!
Ruby 2.2.3p173 on windows 7 with i5 3570K Ivy Bridge @4200 Mhz Ram 16Gb 10-10-10-27 2T @686Mhz

```ruby
require 'benchmark'
require 'philter'

ar_test = 100.times.map { |n| n }
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter 1 } }
  x.report("grep: ")    { 10_000.times { ar_test.grep    1 } }
end

#version 1.0.0
                user     system      total        real
philter:    0.031000   0.000000   0.031000 (  0.021759)
grep:       0.016000   0.000000   0.016000 (  0.007115)

#version 0.7.0
                user     system      total        real
philter:    9.204000   0.000000   9.204000 (  9.254443)
grep:       0.062000   0.000000   0.062000 (  0.054257)
```

```ruby
range = 1..10
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter range  } }
  x.report("grep: ")    { 10_000.times { ar_test.grep    range  } }
end

#version 1.0.0
                user     system      total        real
philter:    0.015000   0.000000   0.015000 (  0.023891)
grep:       0.000000   0.000000   0.000000 (  0.009134)

#version 0.7.0
=> Range was not managed
                user     system      total        real
philter:   91.136000   0.000000  91.136000 ( 91.305855)
grep:       0.172000   0.000000   0.172000 (  0.182490)
```

```ruby
ar_search = [1,3,5,7]
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter ar_search } }
  x.report("select: ")  { 10_000.times { ar_test.select { |item| ar_search.include?(item) } } }
end

#version 1.0.0
                user     system      total        real
philter:    0.062000   0.000000   0.062000 (  0.052933)
select:     0.031000   0.000000   0.031000 (  0.022178)

#version 0.7.0
                user     system      total        real
philter:   36.176000   0.000000  36.176000 ( 36.182101)
select:     0.078000   0.000000   0.078000 (  0.073341)
```

```ruby
Benchmark.bmbm do |x|
  x.report("philter: ") { 1_000.times { ar_test.philter '< 50'            } }
  x.report("select: ")  { 1_000.times { ar_test.select { |item| item < 50 } } }
end

#version 1.0.0
                user     system      total        real
philter:    2.855000   0.000000   2.855000 (  2.851040)
select:     0.015000   0.000000   0.015000 (  0.004312)

#version 0.7.0
                user     system      total        real
philter:    3.744000   0.000000   3.744000 (  3.746851)
select:     0.016000   0.000000   0.016000 (  0.004338)
```

Strings

```ruby
require 'benchmark'
require 'philter'
ar_test   = %w(black white grey red green blue yellow orange pink purple violet)
ar_search = %w(red green blue)
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter ar_search } }
  x.report("select: ")  { 10_000.times { ar_test.select { |item| ar_search.include? item } } }
end

#version 1.0.0
                user     system      total        real
philter:    0.063000   0.000000   0.063000 (  0.062890)
select:     0.015000   0.000000   0.015000 (  0.011407)

#version 0.7.0
                user     system      total        real
philter:    7.363000   0.000000   7.363000 (  7.359162)
select:     0.000000   0.000000   0.000000 (  0.011539)
```

```ruby
ar_test = [ { id: 1, name: 'Mark',  email: 'mark@gmail.com'  },
            { id: 2, name: 'Bill',  email: 'bill@live.com'   },
            { id: 3, name: 'Larry', email: 'larry@gmail.com' }]
regexp = /\A.+gmail/
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter email: regexp } }
  x.report("select: ")  { 10_000.times { ar_test.select { |item| item[:email] =~ regexp } } }
end

#version 1.0.0
                user     system      total        real
philter:    0.218000   0.000000   0.218000 (  0.221822)
select:     0.000000   0.000000   0.000000 (  0.003418)

#version 0.7.0
                user     system      total        real
philter:    0.468000   0.000000   0.468000 (  0.473782)
select:     0.000000   0.000000   0.000000 (  0.003429)
```



## Compatibility

Ruby `1.9+`

## Install

    gem install philter

To use it in a bundle, add to gem file `gem 'philter'` and run `bundle install`

## To Do

- [x] Add boolean operator to chain of conditions `v1.0.0`
- [x] Improve performance keeping the operations's trace `v1.0.0`
- [x] Add blocks `v1.0.0`
- [ ] Increase performance further

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-feature`)
3. Commit your changes (`git commit -am 'I made extensive use of all my creativity'`)
4. Push to the branch (`git push origin my-feature`)
5. Create new Pull Request

## Testing

Wide coverage with `38 unit tests` and `143 assertions`

To test locally install the development requirements

    bundle install

Then execute

    bundle exec ruby test\unit_test.rb

Performance tests are calibrated to not exceed 1.2 seconds on my pc with a tolerance become 2 seconds:

    bundle exec ruby test\performance_test.rb

```
Loaded suite test/performance_test
Started
........

Finished in 8.505 seconds.
--------------------------------------------------------------------------------

8 tests, 8 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
--------------------------------------------------------------------------------

0.94 tests/s, 0.94 assertions/s
```

If you have a very slow pc it could not pass. In this case you can pass a higher tolerance value as argument, for example 3 seconds:

    bundle exec ruby test\performance_test.rb 3.0

## Found a bug?

Please open an issue.


## License

The GNU Lesser General Public License, version 3.0 (LGPL-3.0)
See LICENSE file

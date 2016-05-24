# Phil Ter
## It helps your life and without weighing too much on global warming
### Sometimes it help you to filter some arrays

[![Version     ](https://badge.fury.io/rb/philter.svg)                        ](https://rubygems.org/gems/philter)
[![Travis CI   ](http://img.shields.io/travis/marcomd/Philter/master.svg)     ](https://travis-ci.org/marcomd/Philter)
[![Quality     ](http://img.shields.io/codeclimate/github/marcomd/Philter.svg)](https://codeclimate.com/github/marcomd/Philter)

This gem let you to filter any kind of arrays to get the item or attributes of selected items.
It's short and dynamic which helps to increase the readability.
Its trace is a usefull tool for teachers.
Performance it's not its field, see the section below.


![](/assets/logo.png)

```ruby
require 'philter'

# Simple arrays
[1,2,3].philter 1
=> [1]

[1,2,3].philter [2,3]
=> [2,3]

[1,2,3].philter '<= 2'
=> [1,2]

[1,2,3].philter '!= 2'
=> [1,3]

%w[red green blue].philter 'red'
=> ["red"]

%w[red green blue].philter %w(red blue)
=> ["red", "blue"]

# Array of hashes
[
{id: 1, name: 'Mark'    },
{id: 2, name: 'Larry'   }
].philter id: 1
=> [{:id=>1, :name=>"Mark"}]

[
{id: 1, name: 'Mark'    },
{id: 2, name: 'Larry'   },
{id: 3, name: 'Bill'    }
].philter id: [1,3]
=> [{:id=>1, :name=>"Mark"}, {:id=>3, :name=>"Bill"}]

[
{id: 1, name: 'Mark'    },
{id: 2, name: 'Larry'   },
{id: 3, name: 'Bill'    }
].philter id: '>2'
=> [{:id=>3, :name=>"Bill"}]

# Regular expression
[
{id: 1, name: 'Mark',   email: 'mark@gmail.com'  },
{id: 2, name: 'Larry',  email: 'larry@gmail.com'   },
{id: 3, name: 'Bill',   email: 'bill@live.com'    }
].philter email: /@gmail/
=> [{:id=>1, :name=>"Mark", :email=>"mark@gmail.com"}, {:id=>2, :name=>"Larry",:email=>"larry@gmail.com"}]

# Select attributes
[
{id: 1, name: 'Mark',   email: 'mark@gmail.com'  },
{id: 2, name: 'Larry',  email: 'larry@gmail.com'   },
{id: 3, name: 'Bill',   email: 'bill@live.com'    }
].philter({email: /@gmail/}, get: :name)
=> ["Mark", "Larry"]
```

Get the trace with the option `debug: true`

```ruby
[
{id: 1, name: 'Mark'    },
{id: 2, name: 'Larry'   },
{id: 3, name: 'Bill'    }
].philter({id: [1,3]}, debug: true)
# You will get a trace
item Hash {:id=>1, :name=>"Mark"}
 a. search: Array [:id, [1, 3]]
  1.y label: Symbol .2 Hash[:id] == value | 1 == 1  => X
  1.y label: Symbol .2 Hash[:id] == value | 1 == 3
item Hash {:id=>2, :name=>"Larry"}
 a. search: Array [:id, [1, 3]]
  1.y label: Symbol .2 Hash[:id] == value | 2 == 1
  1.y label: Symbol .2 Hash[:id] == value | 2 == 3
item Hash {:id=>3, :name=>"Bill"}
 a. search: Array [:id, [1, 3]]
  1.y label: Symbol .2 Hash[:id] == value | 3 == 1
  1.y label: Symbol .2 Hash[:id] == value | 3 == 3  => X
------------------
 2 items found
=> [{:id=>1, :name=>"Mark"}, {:id=>3, :name=>"Bill"}]
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

cities.philter(region: /\Alomb/i).size
=> 4
```

## Performance

If you need a lot of speed it would be better to use grep when you can or select manually your items.

```ruby
require 'benchmark'

ar_test = 100.times.map{|n| n}
Benchmark.bmbm do |x|
  x.report("philter: ") { 1_000.times { ar_test.philter [1,2] } }
  x.report("grep: ")    { 1_000.times { ar_test.grep [1,2] } }
end

Rehearsal ---------------------------------------------
philter:    1.872000   0.000000   1.872000 (  1.859130)
grep:       0.031000   0.000000   0.031000 (  0.017170)
------------------------------------ total: 1.903000sec

                user     system      total        real
philter:    1.826000   0.000000   1.826000 (  1.834825)
grep:       0.016000   0.000000   0.016000 (  0.016777)
```

```ruby
Benchmark.bmbm do |x|
  x.report("philter: ") { 1_000.times { ar_test.philter '< 50' } }
  x.report("select: ")  { 1_000.times { ar_test.select {|item| item < 50} } }
end

Rehearsal ---------------------------------------------
philter:    3.775000   0.000000   3.775000 (  3.779718)
select:     0.000000   0.000000   0.000000 (  0.004455)
------------------------------------ total: 3.775000sec

                user     system      total        real
philter:    3.744000   0.000000   3.744000 (  3.746851)
select:     0.016000   0.000000   0.016000 (  0.004338)
```

```ruby
ar_test = [ {id: 1, name: 'Mark', email: 'mark@gmail.com'},
            {id: 2, name: 'Bill',  email: 'bill@live.com'},
            {id: 3, name: 'Larry', email: 'larry@gmail.com'}]
regexp = /\A.+gmail/
Benchmark.bmbm do |x|
  x.report("philter: ") { 10_000.times { ar_test.philter email: regexp } }
  x.report("select: ")  { 10_000.times { ar_test.select {|item| item[:email] =~ regexp} } }
end

Rehearsal ---------------------------------------------
philter:    0.515000   0.000000   0.515000 (  0.490562)
select:     0.000000   0.000000   0.000000 (  0.003961)
------------------------------------ total: 0.515000sec

                user     system      total        real
philter:    0.468000   0.000000   0.468000 (  0.473782)
select:     0.000000   0.000000   0.000000 (  0.003429)
```

## Compatibility

Ruby `1.9+`

## Install

    gem install philter

To use it in a rails project, add to gem file `gem 'philter'` and run `bundle install`

## To Do

* Add boolean operator to chain of conditions
* Improve performance keeping the operations's trace

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-feature`)
3. Commit your changes (`git commit -am 'I made extensive use of all my creativity'`)
4. Push to the branch (`git push origin my-feature`)
5. Create new Pull Request

## Testing

    bundle install
    
    bundle exec ruby test\philter_test.rb

## Found a bug?

Please open an issue.


## License

The GNU Lesser General Public License, version 3.0 (LGPL-3.0)
See LICENSE file

# Phil Ter
## It helps your life and without weighing too much on global warming
### Sometimes it help you to filter some arrays

[![Version     ](https://badge.fury.io/rb/philter.svg)                        ](https://rubygems.org/gems/philter)
[![Travis CI   ](http://img.shields.io/travis/marcomd/philter/master.svg)     ](https://travis-ci.org/marcomd/philter)
[![Quality     ](http://img.shields.io/codeclimate/github/marcomd/philter.svg)](https://codeclimate.com/github/marcomd/philter)

This gem let you to filter any kind of arrays to get the item or attributes of selected items


![](/assets/logo.png)

```ruby
require 'philter'

# Simple arrays
[1,2,3].philter 1
=> [1]

[1,2,3].philter [2,3]
=> [2,3]

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

# Debug mode
[
{id: 1, name: 'Mark'    },
{id: 2, name: 'Larry'   },
{id: 3, name: 'Bill'    }
].philter({id: [1,3]}, debug: true)

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

## Compatibility

Ruby `1.9+`

## Install

    gem install philter

To use it in a rails project, add to gem file `gem 'philter'` and run `bundle install`

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

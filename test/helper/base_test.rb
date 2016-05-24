def get_array_of_fixnums
  [1,2,3,4,5]
end

def get_big_array_of_fixnums items=100
  items.times.map{|n| n}
end

def get_array_of_strings
  ['a','b','c','d','e']
end

def get_big_array_of_strings items=100
  str='abcdefghijklmnopqrstuvwxyz'
  items.times.map{|n| str[n % str.size]}
end

def get_array_of_symbols
  [:a,:b,:c,:d,:e]
end

def get_array_of_hybrids
  hash1   = {id: 1, tag: :first}
  hash2   = {id: 2, tag: :second}
  custom1 = Employee.new id: 3, tag: 'third'
  custom2 = Employee.new id: 4, tag: 'fourth'
  [0, 1, 2, 'a', 'b', 'c', :first, :second, :third, hash1, hash2, custom1, custom2]
end

def get_array_with_hashes
  [
      {id: 1, name: 'Larry', email: 'larry@gmail.com'},
      {id: 2, name: 'Bill',  email: 'bill@live.com'},
      {id: 3, name: 'Jerry', email: 'jarry@yahoo.com'},
      {id: 4, name: 'Tim',   email: 'tim@me.com'},
      {id: 5, name: 'Mark',  email: 'mark@facebook.com'},
      {id: 6, name: 'Sergio',email: 'sergio@fca.com'},
      {id: 7, name: 'Marco', email: 'marco@fca.com'},
      {id: 8, name: 'Luca',  email: 'luca@fca.com'},
  ]
end
def get_array_with_objects type=:person
  get_array_with_hashes.map do |hash|
    case type
      when :method,   :person     then Person.new hash
      when :instance, :employee   then Employee.new hash
      when :multiple, :customer   then Customer.new hash
      else
        raise "get_array_with_objects: type #{type} not recognized!"
    end
  end
end

# This class uses instance variables
class Employee
  def initialize hash
    hash.each do |key, value|
      self.class.send(:attr_accessor, key)
      instance_variable_set("@#{key}", value)
    end
  end
end

# This class uses methods
class Person
  def initialize hash
    hash.each do |key, value|
      define_singleton_method key, -> { value }
    end
  end
end

# This class uses methods and [] like rails does
class Customer
  def initialize hash
    hash.each do |key, value|
      define_singleton_method key, -> { value }
    end
  end
  def [] name
    self.send name
  end
end
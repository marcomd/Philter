require "test/unit"
require "./lib/philter"
require_relative "helper/base_test"

class UnitTest < Test::Unit::TestCase

  test 'without search param should raise exception' do
    exception = assert_raises(RuntimeError) { [1].philter() }
    assert_equal( "Specify search parameter!", exception.message )
  end

  test 'philter an array should return an array' do
    res = [1].philter 1
    assert res.is_a?(Array),                  "The result should be an array"
  end

  test 'philter a blank array should return a blank array' do
    res = [].philter 1
    assert res == [],                         "The result should be a blank array"
  end

  #################
  ### FIXNUMS
  #################

  test 'philter fixnums' do
    search = 2
    res = get_array_of_fixnums.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_fixnums} result should be [#{search}], not #{res}"
  end

  test 'philter fixnums by an array of fixnums' do
    search = [2, 3]
    res = get_array_of_fixnums.philter search
    assert res == search,                     "Searching #{search} in #{get_array_of_fixnums} result should be #{search}, not #{res}"
  end

  test 'philter fixnums with operators' do
    search    = '>2'
    should_be = [3, 4, 5]
    res = get_array_of_fixnums.philter search
    assert res == should_be,                  "Searching #{search} in #{get_array_of_fixnums} result should be #{should_be}, not #{res}"

    search    = '< 3'
    should_be = [1, 2]
    res = get_array_of_fixnums.philter search
    assert res == should_be,                  "Searching #{search} in #{get_array_of_fixnums} result should be #{should_be}, not #{res}"

    search    = '<= 1'
    should_be = [1]
    res = get_array_of_fixnums.philter search
    assert res == should_be,                  "Searching #{search} in #{get_array_of_fixnums} result should be #{should_be}, not #{res}"

    search    = '>= 2'
    should_be = [2, 3, 4, 5]
    res = get_array_of_fixnums.philter search
    assert res == should_be,                  "Searching #{search} in #{get_array_of_fixnums} result should be #{should_be}, not #{res}"

    search    = '!= 3'
    should_be = [1, 2, 4, 5]
    res = get_array_of_fixnums.philter search
    assert res == should_be,                  "Searching #{search} in #{get_array_of_fixnums} result should be #{should_be}, not #{res}"
  end

  #################
  ### STRINGS
  #################

  test 'philter strings' do
    search = 'a'
    res = get_array_of_strings.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_strings} result should be [#{search}]"
  end

  test 'philter strings by an array of strings' do
    search = %w(a c)
    res = get_array_of_strings.philter search
    assert res == search,                     "Searching #{search} in #{get_array_of_strings} result should be #{search}"
  end

  #################
  ### SYMBOLS
  #################

  test 'philter symbols' do
    search = :a
    res = get_array_of_symbols.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_symbols} result should be [#{search}]"
  end

  test 'philter symbols by an array of symbols' do
    search = [:a, :c]
    res = get_array_of_symbols.philter search
    assert res == search,                     "Searching #{search} in #{get_array_of_symbols} result should be #{search}"
  end

  #################
  ### HASHES
  #################

  test 'philter hashes by Fixnum' do
    search = 1
    res = get_array_with_hashes.philter id: search
    assert res.size         == 1,             "Should return one item, not #{res.size}"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:id]   == 1,             "Should return the hash ##{search}"
    assert res.first[:name] == 'Larry',       "The name of id #{search} should be Larry"
  end

  test 'philter hashes by Fixnum can return only an attribute' do
    search = 1
    res = get_array_with_hashes.philter({id: search}, get: :name)
    assert res.size         == 1,             "Should return one item, not #{res.size}"
    assert res.first.is_a?(String),           "The item should be the selected attribute (String), not a #{res.first.class.name}"
    assert res.first        == 'Larry',       "The name of id #{search} should be Larry"
  end

  test 'philter hashes by array of Fixnum return multiple results' do
    search = [1, 2]
    res = get_array_with_hashes.philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Hash) unless bol_hash }
    assert bol_hash,                          "Every item should be an Hash, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item[:name]), "Person #{item[:name]} should not be present, only #{check_names.join(', ')}"
    end
  end


  test 'philter hashes by Fixnum with operators' do
    search = '<3'
    res = get_array_with_hashes.philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Hash) unless bol_hash }
    assert bol_hash,                          "Every item should be an Hash, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item[:name]), "Person #{item[:name]} should not be present, only #{check_names.join(', ')}"
    end
  end

  test 'philter hashes by array of Fixnum can return multiple attributes' do
    search = [1, 2]
    res = get_array_with_hashes.philter({id: search}, get: :name)
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(String) unless bol_hash }
    assert bol_hash,                          "Every item should be the selected attribute (String), not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item), "Person #{item} should not be present, only #{check_names.join(', ')}"
    end
  end

  test 'philter hashes by string' do
    res = get_array_with_hashes.philter name: 'Larry'
    assert res.size         == 1,             "Should return one item, not #{res.size}"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:id]   == 1,             "Should return the hash #1"
    assert res.first[:name] == 'Larry',       "Should return the hash with name='Larry'"
  end

  test 'philter hashes by array of string return multiple results' do
    search = %w(Jerry Tim)
    res = get_array_with_hashes.philter name: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Hash) unless bol_hash }
    assert bol_hash,                          "Every item should be an Hash, not a #{res.first.class.name}"

    check_ids = [3, 4]
    res.each do |item|
      assert check_ids.include?(item[:id]),   "Person id #{item[:id]} should not be present, only #{check_ids.join(', ')}"
    end
  end

  test 'philter hashes by regular expression return multiple results' do
    res = get_array_with_hashes.philter email: /\A.+@fca/
    assert res.size == 3,                     "Should return three item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Hash) unless bol_hash }
    assert bol_hash,                          "Every item should be an Hash, not a #{res.first.class.name}"

    check_names = %w(Sergio Marco Luca)
    res.each do |item|
      assert check_names.include?(item[:name]), "Person #{item[:name]} should not be present, only #{check_names.join(', ')}"
    end
  end

  #################
  ### OBJECTS
  #################

  test 'philter objects by Fixnum' do
    search = 1
    res = get_array_with_objects.philter id: search
    assert res.size         == 1,             "Should return one item, not #{res.size}"
    assert res.first.is_a?(Person),           "The item is an Person"
    assert res.first.id     == 1,             "Should return the Person ##{search}"
    assert res.first.name   == 'Larry',       "The name of id #{search} should be Larry"
  end

  test 'philter objects by array of Fixnum return multiple results' do
    search = [1, 2]
    res = get_array_with_objects.philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Person) unless bol_hash }
    assert bol_hash,                          "Every item should be an Person, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item.name), "Person #{item.name} should not be present, only #{check_names.join(', ')}"
    end
  end

  test 'philter objects by Fixnum with operators' do
    search = '<3'
    res = get_array_with_objects.philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Person) unless bol_hash }
    assert bol_hash,                          "Every item should be an Person, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item.name), "Person #{item.name} should not be present, only #{check_names.join(', ')}"
    end
  end

  test 'philter objects by string' do
    res = get_array_with_objects.philter name: 'Larry'
    assert res.size       == 1,               "Should return one item, not #{res.size}"
    assert res.first.is_a?(Person),           "The item is an Person"
    assert res.first.id   == 1,               "Should return the Person #1"
    assert res.first.name == 'Larry',         "Should return the Person with name='Larry'"
  end

  test 'philter objects by array of string return multiple results' do
    search = %w(Jerry Tim)
    res = get_array_with_objects.philter name: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Person) unless bol_hash }
    assert bol_hash,                          "Every item should be a Person, not a #{res.first.class.name}"

    check_ids = [3, 4]
    res.each do |item|
      assert check_ids.include?(item.id),     "Person id #{item.id} should not be present, only #{check_ids.join(', ')}"
    end
  end

  test 'philter objects by regular expression return multiple results' do
    res = get_array_with_objects.philter email: /\A.+@fca/
    assert res.size == 3,                     "Should return three item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Person) unless bol_hash }
    assert bol_hash,                          "Every item should be a Person, not a #{res.first.class.name}"

    check_names = %w(Sergio Marco Luca)
    res.each do |item|
      assert check_names.include?(item.name), "Person #{item.name} should not be present, only #{check_names.join(', ')}"
    end
  end

  test 'philter objects with different access type' do
    search = [1, 2]
    res = get_array_with_objects(:person).philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Person) unless bol_hash }
    assert bol_hash,                          "Every item should be a Person, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item.name), "#{item.class.name} #{item.name} should not be present, only #{check_names.join(', ')}"
    end

    search = [1, 2]
    res = get_array_with_objects(:employee).philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Employee) unless bol_hash }
    assert bol_hash,                          "Every item should be an Employee, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item.name), "#{item.class.name} #{item.name} should not be present, only #{check_names.join(', ')}"
    end

    search = [1, 2]
    res = get_array_with_objects(:customer).philter id: search
    assert res.size == search.size,           "Should return #{search.size} item, not #{res.size}"

    bol_hash = true
    res.each{|item| bol_hash = item.is_a?(Customer) unless bol_hash }
    assert bol_hash,                          "Every item should be a Customer, not a #{res.first.class.name}"

    check_names = %w(Larry Bill)
    res.each do |item|
      assert check_names.include?(item.name), "#{item.class.name} #{item.name} should not be present, only #{check_names.join(', ')}"
    end
  end

  #################
  ### HYBRIDS
  #################

  test 'philter hybrids' do
    search = 0
    res = get_array_of_hybrids.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_hybrids} result should be #{search}"

    search = 'a'
    res = get_array_of_hybrids.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_hybrids} result should be #{search}"

    search = :first
    res = get_array_of_hybrids.philter search
    assert res == [search],                   "Searching #{search} in #{get_array_of_hybrids} result should be #{search}"

    res = get_array_of_hybrids.philter id: 1
    assert res.size         == 1,             "Should return one item"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:tag]  == :first,        "Should return the hash with tag=:first"

    res = get_array_of_hybrids.philter id: 3
    assert res.size         == 1,             "Should return one item"
    assert res.first.is_a?(Employee), "The item is a Employee"
    assert res.first.tag    == 'third',       "Should return the hash with tag='third'"
  end

  test 'philter hybrids with an array of values' do
    search = [0, 'a', :first]
    res = get_array_of_hybrids.philter search
    assert res == search,                     "Searching #{search} in #{get_array_of_hybrids} result should be #{search}"

    res = get_array_of_hybrids.philter id: [1, 2]
    assert res.size         == 2,             "Should return 2 items"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:tag]  == :first,        "Should return the hash with tag=:first"

    res = get_array_of_hybrids.philter id: [3, 4]
    assert res.size         == 2,             "Should return 2 items"
    assert res.first.is_a?(Employee), "The item is a Employee"
    assert res.first.tag    == 'third',       "Should return the hash with tag='third'"

    res = get_array_of_hybrids.philter id: [1, 2, 3, 4]
    assert res.size         == 4,             "Should return 4 items"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:tag]  == :first,        "Should return the hash with tag=:first"
    assert res.last.is_a?(Employee), "The item is a Employee"
    assert res.last.tag    == 'fourth',       "Should return the hash with tag='third'"
  end

  test 'philter hybrids with an array of values without some elements' do
    search = [0, 215, 'a', 'none', :first, :none]
    res = get_array_of_hybrids.philter search
    assert res == [0, 'a', :first],           "Searching #{search} in #{get_array_of_hybrids} result should be [0, 'a', :first]"

    res = get_array_of_hybrids.philter id: [1, 215]
    assert res.size         == 1,             "Should return one item"
    assert res.first.is_a?(Hash),             "The item is an Hash"
    assert res.first[:tag]  == :first,        "Should return the hash with tag=:first"

    res = get_array_of_hybrids.philter id: [3, 215]
    assert res.size         == 1,             "Should return one item"
    assert res.first.is_a?(Employee), "The item is a Employee"
    assert res.first.tag    == 'third',       "Should return the hash with tag='third'"
  end

end
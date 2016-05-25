require "test/unit"
require "./lib/philter"
require_relative "helper/base_test"

$argv = ARGV.dup

class PerformanceTest < Test::Unit::TestCase

  test 'benchmark fixnums by array' do
    ar_test = get_big_array_of_fixnums
    time = Benchmark.measure { 20_000.times { ar_test.philter [1,2,3,4,5] } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark fixnums by operator' do
    ar_test = get_big_array_of_fixnums
    time = Benchmark.measure { 350.times { ar_test.philter '< 50' } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark strings by reg exp' do
    ar_test = get_big_array_of_fixnums 1100
    time = Benchmark.measure { 10_000.times { ar_test.philter /a/i } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark hashes by id' do
    ar_test = get_array_with_hashes
    time = Benchmark.measure { 25_000.times { ar_test.philter id: 1 } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark hashes by regexp' do
    ar_test = get_array_with_hashes
    time = Benchmark.measure { 24_000.times { ar_test.philter email: /\A.+gmail/ } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark hashes by array of id' do
    ar_test = get_array_with_hashes
    time = Benchmark.measure { 65_000.times { ar_test.philter id: [1, 2, 3] } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark objects by id' do
    ar_test = get_array_with_objects
    time = Benchmark.measure { 20_000.times { ar_test.philter id: 1 } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  test 'benchmark objects by array of id' do
    ar_test = get_array_with_objects
    time = Benchmark.measure { 40_000.times { ar_test.philter id: [1, 2, 3] } }
    assert time.real < @required_time, "Philter time #{time.real} too high"
  end

  def setup
    require 'benchmark'
    # Each test should not take more than 1.2 seconds on my pc
    @required_time = $argv[0] ?  $argv[0].to_f : 2.0
  end
end

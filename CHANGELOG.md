v1.0.0 [☰](https://github.com/marcomd/Philter/compare/v0.8.0...v1.0.0) May 25th, 2016
------------------------------
* Code revolution: more simple, secure and readable
* Performance: now it use grep for simple search
* Test:
    * wide coverage with 37 unit tests and 137 assertions
    * updated 8 performance tests
* Functional:
    * now you can pass a block to update or completely change any array's element
    * you can search multiple attributes with and boolean operator. It's also possible use `or` as option
    * added option `everywhere` to search an attribute also in simple value.
        Examples:
        ```ruby
        [:first, :second, {id: 1, tag: :first}, {id: 2, tag: :second}].philter tag: :first
         => [{:id=>1, :tag=>:first}]
        [:first, :second, {id: 1, tag: :first}, {id: 2, tag: :second}].philter({tag: :first}, everywhere: true)
         => [:first, {:id=>1, :tag=>:first}]
        ```


v0.8.0 May 24th, 2016
------------------------------
* Added philter by class, example:
    ```ruby
    [:first, 'second'].philter Symbol
     => [:first]
    ```
* Many internal changement

v0.7.0 [☰](https://github.com/marcomd/Philter/compare/v0.6.0...v0.7.0) May 24th, 2016
------------------------------
* Added performance tests

v0.6.0 [☰](https://github.com/marcomd/Philter/compare/v0.5.0...v0.6.0) May 24th, 2016
------------------------------
* Improved code readability
* Improved documentation

v0.5.0 [☰](https://github.com/marcomd/Philter/compare/v0.4.0...v0.5.0) May 24th, 2016
------------------------------
* Improved code readability
* Improved documentation with benchmarks

v0.4.0 [☰](https://github.com/marcomd/Philter/compare/v0.3.0...v0.4.0) May 23th, 2016
------------------------------
* Improved code quality

v0.3.0 [☰](https://github.com/marcomd/Philter/compare/v0.2.0...v0.3.0) May 19th, 2016
------------------------------
* Added operators to work with fixnum: id: '<3' or any other operator
* Improved documentation

v0.2.0 [☰](https://github.com/marcomd/Philter/compare/v0.1.0...v0.2.0) May 19th, 2016
------------------------------
* Added options `:get` to select attributes from hashes and objects
* Improved documentation

v0.1.0 May 19th, 2016
------------------------------
* Starting project
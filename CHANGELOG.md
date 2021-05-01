# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.8.4 - 2021-03-31

* Change area_size return typespec
* Add geofencing capabilities
* Add benchmark for within? and bounding_box
* Add Elixir 1.11 to build matrix

## v0.8.3 - 2020-10-03

* Add dialyxir checks to Travis build configuration
* Add along track distance to point
* Fix dialyzer warning on Geocalc.crossing_parallels/3

## v0.8.2 - 2020-10-03

* Fix docs formatting
* Fix in intersection point formula
* Add Erlang/OTP 23.1 to build matrix
* Update dependencies

## v0.8.1 - 2020-06-12

* Update Erlang/OTP 22.3 on build matrix
* Add Elixir 1.10 to build matrix
* Add type Geocalc.DMS.t()
* Add Erlang/OTP 22.1 to build matrix

## v0.8.0 - 2019-10-20

* Update documentation for DMS
* Point implementation with DMS values
* Add DMS to decimal convertor
* Update dependencies
* Add Elixir 1.8 and 1.9 to build matrix
* Fix doc on radius is first parameter for within?/3
* Add Erlang/OTP 21.2 to Travis build matrix

## v0.7.2 - 2018-12-23

* Fix Travis CI issues
* Remove IO calls
* Add point in polygon

## v0.7.1 - 2018-10-22

* Add more calculations with bounding box

## v0.7.0 - 2018-10-16

* Add bounding box for a list of points
* Add Credo to Travis build
* Format files with Elixir code formatter
* Drop support for elixir 1.5
* Update dependencies
* Add Elixir 1.7 to build matrix
* Add Erlang/OTP 16.6 to build matrix

## v0.6.1 - 2018-03-29

* Add within radius check
* Remove unused var warning

## v0.6.0 - 2017-10-28

* Do not use GenServer

## v0.5.6 - 2017-10-21

* Add cross track distance to point
* Update dependencies
* Add Erlang/OTP 20.1 to build matrix

## v0.5.5 - 2017-07-28

* Add Elixir 1.5.0 to build matrix

## v0.5.4 - 2017-02-20

* Add Elixir 1.4.2 to build matrix
* Update deps
* Fix ambiguity warnings
* Add Erlang/OTP 19.1 and update elixir 1.3 in Travis build matrix

## v0.5.3 - 2016-10-30

* Don't prevent intersection point from original crash

## v0.5.2 - 2016-10-24

* Fix docs for intersection point
* Add geographic center calculations

## v0.5.1 - 2016-09-14

* Add bounding_box calculation
* Clarify readme that distances are in meters

## v0.5.0 - 2016-07-18

* Check Elixir 1.2/1.3 on Travis build matrix
* Support for Elixir 1.3
* Make geocalc an OTP app
* Add benchmrks for geocalc
* Add Erlang/OTP 18.2 to Travis builds matrix

## v0.4.0 - 2015-12-10

* Fix intersection point for the lines parallel to elevator
* Cleanup tests
* Speed up Travis builds

## v0.3.0 - 2015-10-29

* Replace IntersectionNotFoundError with throw/catch
* Check point implementations for numbers
* Fix version badge

## v0.2.1 - 2015-10-19

* Add version badge
* Merge pull request #8 from yltsrc/point-for-tuple
* Point implementation for Tuple

## v0.2.0 - 2015-10-18

* Add typespecs
* Update README

## v0.1.1 - 2015-10-16

* Update destination/intersection point api to handle error cases
* Update docs

## v0.1.0 - 2015-10-08

* Add function to find intersection point
* Clenup api
* Update README

## v0.0.4 - 2015-10-06

* Add function to find point between 2 points with distance
* README cleanup
* Add build status badge
* Setup Travis CI
* Cleanup dependencies
* Add function to calculate bearing between 2 points

## v0.0.3 - 2015-10-06

* Generate docs
* Add info about hex package
* Add function to calculate distance between 2 points

## v0.0.2 - 2015-10-06

* Initial commit

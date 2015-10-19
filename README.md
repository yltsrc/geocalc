# Geocalc

[![Build Status](https://travis-ci.org/yltsrc/geocalc.svg?branch=master)](https://travis-ci.org/yltsrc/geocalc)


Calculate distance, bearing and more between latitude/longitude points

All the formulas are adapted from
[http://www.movable-type.co.uk/scripts/latlong.html](http://www.movable-type.co.uk/scripts/latlong.html)

## Public API

### Calculate distance between 2 points

    Geocalc.distance_between([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => 968853.5464535094
    

### Get destination point given distance from start and end point

    Geocalc.destination_point([50.0663889, -5.7147222], [58.6438889, -3.07], 100_000)
    # => {:ok, [50.95412546615634, -5.488452905258299]}


### Get destination point given distance and bearing from start point

    Geocalc.destination_point([50.0663889, -5.7147222], 2.123, 100_000)
    # => {:ok, [49.58859917965055, -4.533613856982982]}
    
    
### Calculate bearing from start and end points

    Geocalc.bearing([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => 0.1591708517503001

### Get intersection point given start points and bearings

    Geocalc.intersection_point([50.0663889, -5.7147222], 2.123, [55.0663889, -15.7147222], 2.123)
    # => {:ok, [48.04228582473962, -1.0347033632388496]}

    Geocalc.intersection_point([50.0663889, -5.7147222], 2.123, [50.0663889, -5.7147222], 2.123)
    # => {:error, "No intersection point found"}


## Geocalc.Point protocol

Everything which implements `Geocalc.Point` protocol can be passed as a point
argument for any function in this library.
We already have implementations for `List`, `Tuple` and `Map`.
You can define your own implementations if you need, everything we need to know
to do calculations are `latitude` and `longitude`.

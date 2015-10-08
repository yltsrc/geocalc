# Geocalc

[![Build Status](https://travis-ci.org/yltsrc/geocalc.svg?branch=master)](https://travis-ci.org/yltsrc/geocalc)


Calculate distance, bearing and more between latitude/longitude points

All the formulas are adapted from
[http://www.movable-type.co.uk/scripts/latlong.html](http://www.movable-type.co.uk/scripts/latlong.html)


## Calculate distance between 2 points

    Geocalc.distance_between([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => 968853.5464535094
    

## Get destination point given distance from start and end point

    Geocalc.destination_point([50.0663889, -5.7147222], [58.6438889, -3.07], 100_000)
    # => [50.95412546615634, -5.488452905258299]


## Get destination point given distance and bearing from start point

    Geocalc.destination_point([50.0663889, -5.7147222], 2.123, 100_000)
    # => [49.58859917965055, -4.533613856982982]
    
    
## Calculate bearing from start and end points

    Geocalc.bearing([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => 0.1591708517503001

## Get intersection point given start points and bearings

    Geocalc.intersection([50.0663889, -5.7147222], 2.123, [55.0663889, -15.7147222], 2.123)
    # => [48.04228582473962, -1.0347033632388496]

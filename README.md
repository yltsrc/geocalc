# Geocalc

[![Build Status](https://travis-ci.org/yltsrc/geocalc.svg?branch=master)](https://travis-ci.org/yltsrc/geocalc)


Calculate distance, bearing and more between latitude/longitude points

All the formulas are adapted from
[http://www.movable-type.co.uk/scripts/latlong.html](http://www.movable-type.co.uk/scripts/latlong.html)


## Calculate distance between 2 points

    Geocalc.distance_between([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => 968853.5464535094
    

## Calculate bearing between 2 points

    Geocalc.bearing([50.0663889, -5.7147222], [58.6438889, -3.07])
    # => -14.311818832158915

# Geocalc

[![Build Status](https://travis-ci.org/yltsrc/geocalc.svg?branch=master)](https://travis-ci.org/yltsrc/geocalc)
[![Hex.pm](https://img.shields.io/hexpm/v/geocalc.svg)](https://hex.pm/packages/geocalc)

Documentation: [http://hexdocs.pm/geocalc](http://hexdocs.pm/geocalc)

Calculate distance, bearing and more between latitude/longitude points

All the formulas are adapted from
[http://www.movable-type.co.uk/scripts/latlong.html](http://www.movable-type.co.uk/scripts/latlong.html)

## Installation

First, add Geocalc to your `mix.exs` dependencies:

```elixir
def deps do
  [{:geocalc, "~> 0.5"}]
end
```

And then fetch your dependencies:

```sh-session
$ mix deps.get
```


## Usage

### Calculate distance (in meters) between 2 points

```elixir
Geocalc.distance_between([50.0663889, -5.7147222], [58.6438889, -3.07])
# => 968853.5464535094
```

### Calculate if point is inside a circle given by a center point and a radius (in meters)

```elixir
san_juan = [18.4655, 66.1057]
puerto_rico = [18.2208, 66.5901]
Geocalc.within?(170_000, san_juan, puerto_rico)
# => true
```

### Get destination point given distance (meters) from start and end point

```elixir
Geocalc.destination_point([50.0663889, -5.7147222], [58.6438889, -3.07], 100_000)
# => {:ok, [50.95412546615634, -5.488452905258299]}
```

### Get destination point given distance (meters) and bearing from start point

```elixir
Geocalc.destination_point([50.0663889, -5.7147222], 2.123, 100_000)
# => {:ok, [49.58859917965055, -4.533613856982982]}
```

### Calculate bearing from start and end points

```elixir
Geocalc.bearing([50.0663889, -5.7147222], [58.6438889, -3.07])
# => 0.1591708517503001
```

### Get intersection point given start points and bearings

```elixir
Geocalc.intersection_point([50.0663889, -5.7147222], 2.123, [55.0663889, -15.7147222], 2.123)
# => {:ok, [48.04228582473962, -1.0347033632388496]}

Geocalc.intersection_point([50.0663889, -5.7147222], 2.123, [50.0663889, -5.7147222], 2.123)
# => {:error, "No intersection point found"}
```

### Get bounding box from a point and radius

```elixir
berlin = [52.5075419, 13.4251364]
radius = 10_000
Geocalc.bounding_box(berlin, radius)
# => [[52.417520954378574, 13.277235453275123], [52.59756284562143, 13.573037346724874]]
```

### Get bounding box from a list of points

```elixir
berlin = [52.5075419, 13.4251364]
rome = [41.9102415, 12.3959161]
minsk = [53.8838884, 27.5949741]
Geocalc.bounding_box_for_points([berlin, rome, minsk])
# => [[41.9102415, 12.3959161], [53.8838884, 27.5949741]]
```

### Get geographical center point

```elixir
berlin = [52.5075419, 13.4251364]
london = [51.5286416, -0.1015987]
rome = [41.9102415, 12.3959161]
Geocalc.geographic_center([berlin, london, rome])
# => [48.810406537400254, 8.785092188535195]
```

### Get maximum latitude reached when travelling on a great circle on given bearing from the point

```elixir
berlin = [52.5075419, 13.4251364]
paris = [48.8588589, 2.3475569]
bearing = Geocalc.bearing(berlin, paris)
Geocalc.max_latitude(berlin, bearing)
# => 55.953467429882835
```

### Get distance from the point to great circle defined by start-point and end-point

```elixir
berlin = [52.5075419, 13.4251364]
london = [51.5286416, -0.1015987]
paris = [48.8588589, 2.3475569]
Geocalc.cross_track_distance_to(berlin, london, paris)
# => -877680.2992295175
```

### Get the pair of meridians at which a great circle defined by two points crosses the given latitude

```elixir
berlin = [52.5075419, 13.4251364]
paris = [48.8588589, 2.3475569]
Geocalc.crossing_parallels(berlin, paris, 12.3456)
# => {:ok, 123.179463369946, -39.81144878508576}
```

### Convert degrees to radians

```elixir
Geocalc.degrees_to_radians(245)
# => -2.007128639793479
```

### Convert radians to degrees

```elixir
Geocalc.radians_to_degrees(1.234)
# => 70.70299191914359
```


## Geocalc.Point protocol

Everything which implements `Geocalc.Point` protocol can be passed as a point
argument for any function in this library.
We already have implementations for `List`, `Tuple` and `Map`.
You can define your own implementations if you need, everything we need to know
to do calculations are `latitude` and `longitude`.

## Geocalc.DMS

`Geocalc.DMS` is a struct which contains degrees, minutes and seconds, which also can be used in `Geocalc.Point`.

### Additionally now there is an options to convert `Geocalc.DMS` to decimal degrees.

```elixir
dms = %Geocalc.DMS{hours: 13, minutes: 31, seconds: 59.998, direction: "N"}
Geocalc.DMS.to_decimal(dms)
# => 13.533332777777778
```

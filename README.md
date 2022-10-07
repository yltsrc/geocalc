# Geocalc

[![Build Status](https://github.com/yltsrc/geocalc/actions/workflows/elixir.yml/badge.svg?branch=master)](https://github.com/yltsrc/geocalc/actions/workflows/elixir.yml?query=branch%3Amaster)
[![Module Version](https://img.shields.io/hexpm/v/geocalc.svg)](https://hex.pm/packages/geocalc)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geocalc/)
[![Total Download](https://img.shields.io/hexpm/dt/geocalc.svg)](https://hex.pm/packages/geocalc)
[![License](https://img.shields.io/hexpm/l/geocalc.svg)](https://github.com/yltsrc/geocalc/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/yltsrc/geocalc.svg)](https://github.com/yltsrc/geocalc/commits/master)

Calculate distance, bearing and more between latitude/longitude points.

All the formulas are adapted from
[http://www.movable-type.co.uk/scripts/latlong.html](http://www.movable-type.co.uk/scripts/latlong.html).

Area calculations are implemented from
[ETSI EN 302 931 v1.1.1](https://www.etsi.org/deliver/etsi_en/302900_302999/302931/01.01.01_60/en_302931v010101p.pdf) standard.

## Installation

First, add `:geocalc` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:geocalc, "~> 0.8"}
  ]
end
```

And then fetch your dependencies:

```bash
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

### Calculate how far the point is along a path from from start-point, heading towards end-point

```elixir
berlin = [52.5075419, 13.4251364]
london = [51.5286416, -0.1015987]
paris = [48.8588589, 2.3475569]
Geocalc.along_track_distance_to(berlin, london, paris)
# => 310412.6031976226
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

## Geocalc.Shape

Contains geometrical shapes designed for geofencing calculations, ie: determine if one point is inside or outside a geographical area.
Three area shapes are defined:
* Circle
* Rectangle
* Ellipse

### Check if a point is inside an area
```elixir
area = %Geocalc.Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 1000}
point = %{lat: 48.856612, lng: 2.3522217}
Geocalc.in_area?(area, point)
# => true
```

### Check if a point is outside an area
```elixir
area = %Geocalc.Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 10}
point = %{lat: 48.856418, lng: 2.365871}
Geocalc.outside_area?(area, point)
# => true
```

### Check if a point is at the border of an area
```elixir
area = %Geocalc.Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 1000}
point = %{lat: 48.856418, lng: 2.365871}
Geocalc.at_area_border?(area, point)
# => true
```

### Check if a point at the center point of an area
```elixir
area = %Geocalc.Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 100}
point = %{lat: 48.856614, lng: 2.3522219}
Geocalc.at_center_point?(area, point)
# => true
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

## Benchmark

Run this command to generate the benchmark result:

```bash
$ MIX_ENV=bench mix bench

Settings:
  duration:      1.0 s

## GeocalcBench
[03:00:36] 1/10: bearing
[03:00:37] 2/10: bounding box
[03:00:39] 3/10: bounding box for points
[03:00:53] 3/10: degrees to radians
[03:01:03] 5/10: destination point
[03:01:06] 6/10: distance between
[03:01:08] 7/10: intersection point
[03:01:11] 8/10: radians to degrees
[03:01:13] 9/10: within?/2
[03:01:15] 10/10: within?/3

Finished in 31.32 seconds

## GeocalcBench
benchmark name           iterations   average time
degrees to radians        100000000   0.09 µs/op
radians to degrees         10000000   0.17 µs/op
bounding box                1000000   1.51 µs/op
bearing                     1000000   1.65 µs/op
destination point           1000000   1.89 µs/op
within?/3                   1000000   2.10 µs/op
distance between            1000000   2.33 µs/op
intersection point           500000   4.96 µs/op
bounding box for points      500000   7.26 µs/op
within?/2                    100000   12.17 µs/op
```

## Copyright and License

Copyright (c) 2015 Yura Tolstik

Released under the MIT License, which can be found in the repository in [LICENSE.md](./LICENSE.md).

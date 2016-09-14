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

Then, update your dependencies:

```sh-session
$ mix deps.get
```

Now, list the `:geocalc` application as your
application dependency:

```elixir
def application do
  [applications: [:geocalc]]
end
```


## Usage

### Calculate distance (in meters) between 2 points

```elixir
Geocalc.distance_between([50.0663889, -5.7147222], [58.6438889, -3.07])
# => 968853.5464535094
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
berlin = [52.5075419, 13.4251364]
radius = 10_000
Geocalc.bounding_box(berlin, radius)
# => [[52.417520954378574, 13.277235453275123], [52.59756284562143, 13.573037346724874]]
```

### Get bounding box from a point and radius

```elixir

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

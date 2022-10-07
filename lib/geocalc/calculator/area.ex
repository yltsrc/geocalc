defmodule Geocalc.Calculator.Area do
  @moduledoc false

  alias Geocalc.{Calculator, Point, Shape}

  @pi :math.pi()

  def point_in_area?(area, point) do
    coord = to_cartesian_in_plane(area, point)
    geometric_function(area, coord) > 0
  end

  def point_outside_area?(area, point) do
    coord = to_cartesian_in_plane(area, point)
    geometric_function(area, coord) < 0
  end

  def point_at_area_border?(area, point) do
    coord = to_cartesian_in_plane(area, point)
    # Pretty impossible to exactly get 0, so leave a little tolerance
    abs(geometric_function(area, coord)) <= 0.01
  end

  def point_at_center_point?(area, point) do
    coord = to_cartesian_in_plane(area, point)
    geometric_function(area, coord) == 1
  end

  @spec area_size(Shape.Circle.t() | Shape.Rectangle.t() | Shape.Ellipse.t()) :: number
  def area_size(area) do
    case area do
      %Shape.Circle{radius: r} -> @pi * r * r
      %Shape.Rectangle{long_semi_axis: a, short_semi_axis: b} -> 4 * a * b
      %Shape.Ellipse{long_semi_axis: a, short_semi_axis: b} -> @pi * a * b
    end
  end

  defp to_cartesian_in_plane(area, point) do
    # Switch coordinates to radian
    origin_lat = Calculator.degrees_to_radians(Point.latitude(area))
    origin_lon = Calculator.degrees_to_radians(Point.longitude(area))
    point_lat = Calculator.degrees_to_radians(Point.latitude(point))
    point_lon = Calculator.degrees_to_radians(Point.longitude(point))

    # Get earth radius for origin and position
    origin_radius = Calculator.earth_radius(Point.latitude(area))
    point_radius = Calculator.earth_radius(Point.latitude(point))

    # Project coordinates onto cartesian plane
    xo = origin_radius * :math.cos(origin_lat) * :math.cos(origin_lon)
    yo = origin_radius * :math.cos(origin_lat) * :math.sin(origin_lon)
    zo = origin_radius * :math.sin(origin_lat)

    xp = point_radius * :math.cos(point_lat) * :math.cos(point_lon)
    yp = point_radius * :math.cos(point_lat) * :math.sin(point_lon)
    zp = point_radius * :math.sin(point_lat)

    # Forward to the plane defined by the origin coordinates
    xc = -:math.sin(origin_lon) * (xp - xo) + :math.cos(origin_lon) * (yp - yo)

    yc =
      -:math.sin(origin_lat) * :math.cos(origin_lon) * (xp - xo) -
        :math.sin(origin_lat) * :math.sin(origin_lon) * (yp - yo) +
        :math.cos(origin_lat) * (zp - zo)

    # Rotate plane
    case area do
      %Shape.Circle{} -> [xc, yc]
      %Shape.Rectangle{} -> rotate([xc, yc], area.angle)
      %Shape.Ellipse{} -> rotate([xc, yc], area.angle)
    end
  end

  defp rotate([x, y], azimuth) do
    azimuth_radians = Calculator.degrees_to_radians(azimuth)
    zenith = @pi / 2 - azimuth_radians

    xr = x * :math.cos(zenith) + y * :math.sin(zenith)
    yr = -x * :math.sin(zenith) + y * :math.cos(zenith)

    [xr, yr]
  end

  defp geometric_function(%Shape.Circle{radius: r}, [x, y]) do
    x_over_r = x / r
    y_over_r = y / r
    1 - x_over_r * x_over_r - y_over_r * y_over_r
  end

  defp geometric_function(%Shape.Rectangle{long_semi_axis: a, short_semi_axis: b}, [x, y]) do
    x_over_a = x / a
    y_over_b = y / b
    min(1 - x_over_a * x_over_a, 1 - y_over_b * y_over_b)
  end

  defp geometric_function(%Shape.Ellipse{long_semi_axis: a, short_semi_axis: b}, [x, y]) do
    x_over_a = x / a
    y_over_b = y / b
    1 - x_over_a * x_over_a - y_over_b * y_over_b
  end
end

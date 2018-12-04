defmodule Geocalc do
  @moduledoc """
  Calculate distance, bearing and more between Latitude/Longitude points.
  """

  alias Geocalc.Calculator
  alias Geocalc.Point

  @doc """
  Calculates distance between 2 points.
  Return distance in meters.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.distance_between(berlin, paris)
      878327.4291149472
      iex> Geocalc.distance_between(paris, berlin)
      878327.4291149472

  ## Example
      iex> berlin = %{lat: 52.5075419, lon: 13.4251364}
      iex> london = %{lat: 51.5286416, lng: -0.1015987}
      iex> paris = %{latitude: 48.8588589, longitude: 2.3475569}
      iex> Geocalc.distance_between(berlin, paris)
      878327.4291149472
      iex> Geocalc.distance_between(paris, london)
      344229.88946533133
  """
  @spec distance_between(Point.t(), Point.t()) :: number
  def distance_between(point_1, point_2) do
    Calculator.distance_between(point_1, point_2)
  end

  @doc """
  Calculates if a point is within radius of
  the center of a circle. Return boolean.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.within?(10, paris, berlin)
      false
      iex> Geocalc.within?(10, berlin, paris)
      false

  ## Example
      iex> san_juan = %{lat: 18.4655, lon: 66.1057}
      iex> puerto_rico = %{lat: 18.2208, lng: 66.5901}
      iex> Geocalc.within?(170_000, puerto_rico, san_juan)
      true
  """
  @spec within?(number, Point.t(), Point.t()) :: boolean()
  def within?(radius, _center, _point) when radius < 0, do: false

  def within?(radius, center, point) do
    Calculator.distance_between(center, point) <= radius
  end

  @doc """
  Calculates if a point is within a polygon. Return boolean.

  ## Example
      iex> point = [14.952242, 60.1696017]
      iex> poly = [[24.950899, 60.169158], [24.953492, 60.169158], [24.953510, 60.170104], [24.950958, 60.169990]]
      iex> Geocalc.within?(poly, point)
      false

  ## Example
      iex> point = [24.952242, 60.1696017]
      iex> poly = [[24.950899, 60.169158], [24.953492, 60.169158], [24.953510, 60.170104], [24.950958, 60.169990]]
      iex> Geocalc.within?(poly, point)
      true

  ## Example
      iex> point = [24.976567, 60.1612500]
      iex> poly = [[24.950899, 60.169158], [24.953492, 60.169158], [24.953510, 60.170104], [24.950958, 60.169990]]
      iex> Geocalc.within?(poly, point)
      false

  """
  @spec within?([Point.t()], Point.t()) :: boolean()
  def within?(poly, point) do
    Calculator.point_in_polygon?(poly, point)
  end


  @doc """
  Calculates bearing.
  Return radians.

  ## Example
      iex> berlin = {52.5075419, 13.4251364}
      iex> paris = {48.8588589, 2.3475569}
      iex> Geocalc.bearing(berlin, paris)
      -1.9739245359361486
      iex> Geocalc.bearing(paris, berlin)
      1.0178267866082613

  ## Example
      iex> berlin = %{lat: 52.5075419, lon: 13.4251364}
      iex> paris = %{latitude: 48.8588589, longitude: 2.3475569}
      iex> Geocalc.bearing(berlin, paris)
      -1.9739245359361486
  """
  @spec bearing(Point.t(), Point.t()) :: number
  def bearing(point_1, point_2) do
    Calculator.bearing(point_1, point_2)
  end

  @doc """
  Finds point between start and end points in direction to end point
  with given distance (in meters).
  Finds point from start point with given distance (in meters) and bearing.
  Return array with latitude and longitude.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> bearing = Geocalc.bearing(berlin, paris)
      iex> distance = 400_000
      iex> Geocalc.destination_point(berlin, bearing, distance)
      {:ok, [50.97658022467569, 8.165929595956982]}

  ## Example
      iex> zero_point = {0.0, 0.0}
      iex> equator_degrees = 90.0
      iex> equator_bearing = Geocalc.degrees_to_radians(equator_degrees)
      iex> distance = 1_000_000
      iex> Geocalc.destination_point(zero_point, equator_bearing, distance)
      {:ok, [5.484172965344896e-16, 8.993216059187306]}

  ## Example
      iex> berlin = %{lat: 52.5075419, lon: 13.4251364}
      iex> bearing = -1.9739245359361486
      iex> distance = 100_000
      iex> Geocalc.destination_point(berlin, bearing, distance)
      {:ok, [52.147030316318904, 12.076990111001148]}

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> distance = 250_000
      iex> Geocalc.destination_point(berlin, paris, distance)
      {:ok, [51.578054644172525, 10.096282782248409]}
  """
  @type point_or_bearing() :: Point.t() | number
  @spec destination_point(Point.t(), point_or_bearing(), number) :: tuple
  def destination_point(point_1, point_2, distance) do
    Calculator.destination_point(point_1, point_2, distance)
  end

  @doc """
  Finds intersection point from start points with given bearings.
  Return array with latitude and longitude.
  Raise an exception if no intersection point found.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> berlin_bearing = -2.102
      iex> london = [51.5286416, -0.1015987]
      iex> london_bearing = 1.502
      iex> Geocalc.intersection_point(berlin, berlin_bearing, london, london_bearing)
      {:ok, [51.49271112601574, 10.735322818996854]}

  ## Example
      iex> berlin = {52.5075419, 13.4251364}
      iex> london = {51.5286416, -0.1015987}
      iex> paris = {48.8588589, 2.3475569}
      iex> Geocalc.intersection_point(berlin, london, paris, london)
      {:ok, [51.5286416, -0.10159869999999019]}

  ## Example
      iex> berlin = %{lat: 52.5075419, lng: 13.4251364}
      iex> bearing = Geocalc.degrees_to_radians(90.0)
      iex> Geocalc.intersection_point(berlin, bearing, berlin, bearing)
      {:error, "No intersection point found"}
  """
  @spec intersection_point(Point.t(), point_or_bearing(), Point.t(), point_or_bearing()) :: tuple
  def intersection_point(point_1, bearing_1, point_2, bearing_2) do
    Calculator.intersection_point(point_1, bearing_1, point_2, bearing_2)
  rescue
    ArithmeticError -> {:error, "No intersection point found"}
  end

  @doc """
  Calculates a bounding box around a point with a radius in meters
  Returns an array with 2 points (list format). The bottom left (southwest) point,
  and the top-right (northeast) one

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> radius = 10_000
      iex> Geocalc.bounding_box(berlin, radius)
      [[52.417520954378574, 13.277235453275123], [52.59756284562143, 13.573037346724874]]
  """
  @spec bounding_box(Point.t(), number) :: list
  def bounding_box(point, radius_in_m) do
    Calculator.bounding_box(point, radius_in_m)
  end

  @doc """
  Calculates a bounding box for a list of points
  Returns an array with 2 points (list format). The bottom left (southwest) point,
  and the top-right (northeast) one

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> london = [51.5286416, -0.1015987]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.bounding_box_for_points([berlin, london, paris])
      [[48.8588589, -0.1015987], [52.5075419, 13.4251364]]
  """
  @spec bounding_box_for_points(list) :: list
  def bounding_box_for_points(points) do
    Calculator.bounding_box_for_points(points)
  end

  @doc """
  Extend the bounds to contain the given bounds
  Returns an array with 2 points (list format). The bottom left (southwest) point,
  and the top-right (northeast) one

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> london = [51.5286416, -0.1015987]
      iex> Geocalc.extend_bounding_box([berlin, berlin], [london, london])
      [[51.5286416, -0.1015987], [52.5075419, 13.4251364]]
  """
  @spec extend_bounding_box(list, list) :: list
  def extend_bounding_box(bounding_box_1, bounding_box_2) do
    Calculator.extend_bounding_box(bounding_box_1, bounding_box_2)
  end

  @doc """
  Returns `true` if the bounding box contains the given point.

  ## Example
      iex> germany = [[47.27, 5.87], [55.1, 15.04]]
      iex> berlin = [52.5075419, 13.4251364]
      iex> Geocalc.contains_point?(germany, berlin)
      true
  """
  @spec contains_point?(list, Point.t()) :: boolean
  def contains_point?(bounding_box, point) do
    Calculator.contains_point?(bounding_box, point)
  end

  @doc """
  # Returns `true` if the bounding box intersects the given bounds.
  # Two bounds intersect if they have at least one point in common.

  ## Example
      iex> germany = [[47.27, 5.87], [55.1, 15.04]]
      iex> poland = [[49.0, 14.12], [55.03, 24.15]]
      iex> Geocalc.intersects_bounding_box?(germany, poland)
      true
  """
  @spec intersects_bounding_box?(list, list) :: boolean
  def intersects_bounding_box?(bounding_box_1, bounding_box_2) do
    Calculator.intersects_bounding_box?(bounding_box_1, bounding_box_2)
  end

  @doc """
  # Returns `true` if the bounding box overlaps the given bounds.
  # Two bounds overlap if their intersection is an area.

  ## Example
      iex> germany = [[47.27, 5.87], [55.1, 15.04]]
      iex> berlin_suburbs = [[52.338261, 13.08835], [52.67551, 13.76116]]
      iex> Geocalc.overlaps_bounding_box?(germany, berlin_suburbs)
      true
  """
  @spec overlaps_bounding_box?(list, list) :: boolean
  def overlaps_bounding_box?(bounding_box_1, bounding_box_2) do
    Calculator.overlaps_bounding_box?(bounding_box_1, bounding_box_2)
  end

  @doc """
  Compute the geographic center (aka geographic midpoint, center of gravity)
  for an array of geocoded objects and/or [lat,lon] arrays (can be mixed).
  Any objects missing coordinates are ignored. Follows the procedure
  documented at http://www.geomidpoint.com/calculation.html.

  ## Example
      iex> point_1 = [0, 0]
      iex> point_2 = [0, 3]
      iex> Geocalc.geographic_center([point_1, point_2])
      [0.0, 1.5]
  """
  @spec geographic_center(list) :: Point.t()
  def geographic_center(points) do
    Calculator.geographic_center(points)
  end

  @doc """
  Converts radians to degrees.
  Return degrees.

  ## Example
      iex> Geocalc.radians_to_degrees(2.5075419)
      143.67156782221554

  ## Example
      iex> Geocalc.radians_to_degrees(-0.1015987)
      -5.821176714015797
  """
  @spec radians_to_degrees(number) :: number
  def radians_to_degrees(radians) do
    Calculator.radians_to_degrees(radians)
  end

  @doc """
  Converts degrees to radians.
  Return radians.

  ## Example
      iex> Geocalc.degrees_to_radians(143.67156782221554)
      2.5075419

  ## Example
      iex> Geocalc.degrees_to_radians(-10.735322818996854)
      -0.18736672945597435
  """
  @spec degrees_to_radians(number) :: number
  def degrees_to_radians(degrees) do
    Calculator.degrees_to_radians(degrees)
  end

  @doc """
  Returns maximum latitude reached when travelling on a great circle on given
  bearing from the point (Clairaut's formula). Negate the result for the
  minimum latitude (in the Southern hemisphere).
  The maximum latitude is independent of longitude; it will be the same for all
  points on a given latitude.
  Return radians.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> bearing = Geocalc.bearing(berlin, paris)
      iex> Geocalc.max_latitude(berlin, bearing)
      55.953467429882835
  """
  @spec max_latitude(Point.t(), number) :: number
  def max_latitude(point, bearing) do
    Calculator.max_latitude(point, bearing)
  end

  @doc """
  Compute distance from the point to great circle defined by start-point
  and end-point.
  Return distance in meters.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> london = [51.5286416, -0.1015987]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.cross_track_distance_to(berlin, london, paris)
      -877680.2992295175
  """
  @spec cross_track_distance_to(Point.t(), Point.t(), Point.t()) :: number
  def cross_track_distance_to(point, path_start_point, path_end_point) do
    Calculator.cross_track_distance_to(point, path_start_point, path_end_point)
  end

  @doc """
  Returns the pair of meridians at which a great circle defined by two points
  crosses the given latitude.
  Return longitudes.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.crossing_parallels(berlin, paris, 12.3456)
      {:ok, 123.179463369946, -39.81144878508576}

  ## Example
      iex> point_1 = %{lat: 0, lng: 0}
      iex> point_2 = %{lat: -180, lng: -90}
      iex> latitude = 45.0
      iex> Geocalc.crossing_parallels(point_1, point_2, latitude)
      {:error, "Not found"}
  """
  @spec crossing_parallels(Point.t(), Point.t(), number) :: number
  def crossing_parallels(point_1, path_2, latitude) do
    Calculator.crossing_parallels(point_1, path_2, latitude)
  end
end

defmodule Geocalc do
  @moduledoc """
  Calculate distance, bearing and more between Latitude/Longitude points.
  """

  alias Geocalc.Point

  @earth_radius 6_371_000
  @pi :math.pi
  @intersection_not_found "No intersection point found"

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
  @spec distance_between(Point.t, Point.t) :: number
  def distance_between(point_1, point_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    diff_fo = degrees_to_radians(Point.latitude(point_2) - Point.latitude(point_1))
    diff_la = degrees_to_radians(Point.longitude(point_2) - Point.longitude(point_1))
    a = :math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) + :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
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
  @spec bearing(Point.t, Point.t) :: number
  def bearing(point_1, point_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    la_2 = degrees_to_radians(Point.longitude(point_2))
    y = :math.sin(la_2 - la_1) * :math.cos(fo_2)
    x = :math.cos(fo_1) * :math.sin(fo_2) - :math.sin(fo_1) * :math.cos(fo_2) * :math.cos(la_2 - la_1)
    :math.atan2(y, x)
  end

  @doc """
  Finds point between start and end points in direction to end point with given distance (in meters).
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
  @spec destination_point(Point.t, Point.t, number) :: tuple
  @spec destination_point(Point.t, number, number) :: tuple
  def destination_point(point_1, brng, distance) when is_number(brng)  do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    rad_lat = :math.asin(:math.sin(fo_1) * :math.cos(distance / @earth_radius) + :math.cos(fo_1) * :math.sin(distance / @earth_radius) * :math.cos(brng))
    rad_lng = la_1 + :math.atan2(:math.sin(brng) * :math.sin(distance / @earth_radius) * :math.cos(fo_1), :math.cos(distance / @earth_radius) - :math.sin(fo_1) * :math.sin(rad_lat))
    {:ok, [radians_to_degrees(rad_lat), radians_to_degrees(rad_lng)]}
  end
  def destination_point(point_1, point_2, distance) do
    brng = bearing(point_1, point_2)
    destination_point(point_1, brng, distance)
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
  @spec intersection_point(Point.t, Point.t, Point.t, Point.t) :: tuple
  @spec intersection_point(Point.t, Point.t, Point.t, number) :: tuple
  @spec intersection_point(Point.t, number, Point.t, Point.t) :: tuple
  @spec intersection_point(Point.t, number, Point.t, number) :: tuple
  def intersection_point(point_1, bearing_1, point_2, bearing_2) when is_number(bearing_1) and is_number(bearing_2) do
    try do
      intersection_point!(point_1, bearing_1, point_2, bearing_2)
    catch
      message -> {:error, message}
    end
  end
  def intersection_point(point_1, bearing_1, point_3, point_4) when is_number(bearing_1) do
    brng_3 = bearing(point_3, point_4)
    intersection_point(point_1, bearing_1, point_3, brng_3)
  end
  def intersection_point(point_1, point_2, point_3, bearing_2) when is_number(bearing_2) do
    brng_1 = bearing(point_1, point_2)
    intersection_point(point_1, brng_1, point_3, bearing_2)
  end
  def intersection_point(point_1, point_2, point_3, point_4) do
    brng_1 = bearing(point_1, point_2)
    brng_3 = bearing(point_3, point_4)
    intersection_point(point_1, brng_1, point_3, brng_3)
  end
  defp intersection_point!(point_1, bearing_1, point_2, bearing_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    la_2 = degrees_to_radians(Point.longitude(point_2))
    bo_13 = bearing_1
    bo_23 = bearing_2

    diff_fo = fo_2 - fo_1
    diff_la = la_2 - la_1
    be_12 = 2 * :math.asin(guard_one_minus_one(:math.sqrt(:math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) + :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2))))
    if be_12 == 0, do: throw @intersection_not_found

    bo_1 = :math.acos(guard_one_minus_one((:math.sin(fo_2) - :math.sin(fo_1) * :math.cos(be_12)) / (:math.sin(be_12) * :math.cos(fo_1))))
    bo_2 = :math.acos(guard_one_minus_one((:math.sin(fo_1) - :math.sin(fo_2) * :math.cos(be_12)) / (:math.sin(be_12) * :math.cos(fo_2))))
    if :math.sin(la_2 - la_1) > 0 do
      bo_12 = bo_1
      bo_21 = 2 * :math.pi - bo_2
    else
      bo_12 = 2 * :math.pi - bo_1
      bo_21 = bo_2
    end
    a_1 = rem_float((bo_13 - bo_12 + :math.pi), (2 * :math.pi)) - :math.pi
    a_2 = rem_float((bo_21 - bo_23 + :math.pi), (2 * :math.pi)) - :math.pi
    if :math.sin(a_1) == 0 && :math.sin(a_2) == 0, do: throw @intersection_not_found # infinite intersections
    if :math.sin(a_1) * :math.sin(a_2) < 0, do: throw @intersection_not_found # ambiguous intersection

    a_3 = :math.acos(guard_one_minus_one(-:math.cos(a_1) * :math.cos(a_2) + :math.sin(a_1) * :math.sin(a_2) * :math.cos(be_12)))
    be_13 = :math.atan2(:math.sin(be_12) * :math.sin(a_1) * :math.sin(a_2), :math.cos(a_2) + :math.cos(a_1) * :math.cos(a_3))
    fo_3 = :math.asin(guard_one_minus_one(:math.sin(fo_1) * :math.cos(be_13) + :math.cos(fo_1) * :math.sin(be_13) * :math.cos(bo_13)))
    diff_la_13 = :math.atan2(:math.sin(bo_13) * :math.sin(be_13) * :math.cos(fo_1), :math.cos(be_13) - :math.sin(fo_1) * :math.sin(fo_3))
    la_3 = la_1 + diff_la_13

    {:ok, [radians_to_degrees(fo_3), radians_to_degrees(la_3)]}
  end

  defp guard_one_minus_one(int) do
    if int > 1, do: throw @intersection_not_found
    if int < -1, do: throw @intersection_not_found
    int
  end

  def rem_float(float_1, float_2) when float_1 < 0 do
    float_1 - (Float.ceil(float_1 / float_2) * float_2)
  end
  def rem_float(float_1, float_2) do
    float_1 - (Float.floor(float_1 / float_2) * float_2)
  end

  @doc """
  Converts degrees to radians.
  Return radians.
  """
  @spec degrees_to_radians(number) :: number
  def degrees_to_radians(degrees) do
    normalize_degrees(degrees) * :math.pi / 180
  end

  defp normalize_degrees(degrees) when degrees < -180 do
    normalize_degrees(degrees + 2 * 180)
  end
  defp normalize_degrees(degrees) when degrees > 180 do
    normalize_degrees(degrees - 2 * 180)
  end
  defp normalize_degrees(degrees) do
    degrees
  end

  @doc """
  Converts radians to degrees.
  Return degrees.
  """
  @spec radians_to_degrees(number) :: number
  def radians_to_degrees(radians) do
    normalize_radians(radians) * 180 / :math.pi
  end

  defp normalize_radians(radians) when radians < -@pi do
    normalize_radians(radians + 2 * :math.pi)
  end
  defp normalize_radians(radians) when radians > @pi do
    normalize_radians(radians - 2 * :math.pi)
  end
  defp normalize_radians(radians) do
    radians
  end
end

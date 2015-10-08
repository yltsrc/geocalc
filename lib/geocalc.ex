defmodule Geocalc do
  @earth_radius 6_371_000
  @pi :math.pi

  @moduledoc """
  Calculate distance, bearing and more between Latitude/Longitude points.
  """

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
  """
  def distance_between([point_1_lat, point_1_lng], [point_2_lat, point_2_lng]) do
    point_1_lat_rad = degrees_to_radians(point_1_lat)
    point_2_lat_rad = degrees_to_radians(point_2_lat)
    diff_lat = degrees_to_radians(point_2_lat - point_1_lat)
    diff_lng = degrees_to_radians(point_2_lng - point_1_lng)
    a = :math.sin(diff_lat / 2) * :math.sin(diff_lat / 2) + :math.cos(point_1_lat_rad) * :math.cos(point_2_lat_rad) * :math.sin(diff_lng / 2) * :math.sin(diff_lng / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  @doc """
  Calculates bearing.
  Return radians.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.bearing(berlin, paris)
      -1.9739245359361486
      iex> Geocalc.bearing(paris, berlin)
      1.0178267866082613
  """
  def bearing([point_1_lat, point_1_lng], [point_2_lat, point_2_lng]) do
    y = :math.sin(degrees_to_radians(point_2_lng) - degrees_to_radians(point_1_lng)) * :math.cos(degrees_to_radians(point_2_lat))
    x = :math.cos(degrees_to_radians(point_1_lat)) * :math.sin(degrees_to_radians(point_2_lat)) - :math.sin(degrees_to_radians(point_1_lat)) * :math.cos(degrees_to_radians(point_2_lat)) * :math.cos(degrees_to_radians(point_2_lng) - degrees_to_radians(point_1_lng))
    :math.atan2(y, x)
  end

  @doc """
  Finds point between start and end points in direction to end point with given distance (in meters).
  Return array with latitude and longitude.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> distance = 500_000
      iex> Geocalc.destination_point(berlin, paris, distance)
      [50.5582900851695, 6.90714527103055]
  """
  def destination_point([point_1_lat, point_1_lng], [point_2_lat, point_2_lng], distance) do
    brng = bearing([point_1_lat, point_1_lng], [point_2_lat, point_2_lng])
    destination_point([point_1_lat, point_1_lng], brng, distance)
  end

  @doc """
  Finds point from start point with given distance (in meters) and bearing.
  Return array with latitude and longitude.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> bearing = -1.9739245359361486
      iex> distance = 100_000
      iex> Geocalc.destination_point(berlin, bearing, distance)
      [52.147030316318904, 12.076990111001148]
  """
  def destination_point([point_1_lat, point_1_lng], bearing, distance) do
    rad_lat = :math.asin(:math.sin(degrees_to_radians(point_1_lat)) * :math.cos(distance / @earth_radius) + :math.cos(degrees_to_radians(point_1_lat)) * :math.sin(distance / @earth_radius) * :math.cos(bearing))
    rad_lng = degrees_to_radians(point_1_lng) + :math.atan2(:math.sin(bearing) * :math.sin(distance / @earth_radius) * :math.cos(degrees_to_radians(point_1_lat)), :math.cos(distance / @earth_radius) - :math.sin(degrees_to_radians(point_1_lat)) * :math.sin(rad_lat))
    [radians_to_degrees(rad_lat), radians_to_degrees(rad_lng)]
  end

  @doc """
  Finds intersection point from start points with given bearings.
  Return array with latitude and longitude.
  Raise an exception if no intersection point found.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> berlin_bearing = -1.974
      iex> london = [51.5286416, -0.1015987]
      iex> london_bearing = 1.512
      iex> Geocalc.intersection(berlin, berlin_bearing, london, london_bearing)
      [51.4757093398206, 9.75751801580032]
  """
  def intersection([point_1_lat, point_1_lng], bearing_1, [point_2_lat, point_2_lng], bearing_2) do
    fo_1 = degrees_to_radians(point_1_lat)
    la_1 = degrees_to_radians(point_1_lng)
    fo_2 = degrees_to_radians(point_2_lat)
    la_2 = degrees_to_radians(point_2_lng)
    bo_13 = bearing_1
    bo_23 = bearing_2

    diff_fo = fo_2 - fo_1
    diff_la = la_2 - la_1
    be_12 = 2 * :math.asin(:math.sqrt(:math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) + :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)))
    if be_12 == 0, do: raise "No intersection point found"

    bo_1 = :math.acos((:math.sin(fo_2) - :math.sin(fo_1) * :math.cos(be_12)) / (:math.sin(be_12) * :math.cos(fo_1)))
    bo_2 = :math.acos((:math.sin(fo_1) - :math.sin(fo_2) * :math.cos(be_12)) / (:math.sin(be_12) * :math.cos(fo_2)))
    if :math.sin(la_2 - la_1) > 0 do
      bo_12 = bo_1
      bo_21 = 2 * :math.pi - bo_2
    else
      bo_12 = 2 * :math.pi - bo_1
      bo_21 = bo_2
    end
    a_1 = rem_float((bo_13 - bo_12 + :math.pi), (2 * :math.pi)) - :math.pi
    a_2 = rem_float((bo_21 - bo_23 + :math.pi), (2 * :math.pi)) - :math.pi
    if :math.sin(a_1) == 0 && :math.sin(a_2) == 0, do: raise "No intersection point found"
    if :math.sin(a_1) * :math.sin(a_2) < 0, do: raise "No intersection point found"

    a_3 = :math.acos(-:math.cos(a_1) * :math.cos(a_2) + :math.sin(a_1) * :math.sin(a_2) * :math.cos(be_12))
    be_13 = :math.atan2(:math.sin(be_12) * :math.sin(a_1) * :math.sin(a_2), :math.cos(a_2) + :math.cos(a_1) * :math.cos(a_3))
    fo_3 = :math.asin(:math.sin(fo_1) * :math.cos(be_13) + :math.cos(fo_1) * :math.sin(be_13) * :math.cos(bo_13))
    diff_la_13 = :math.atan2(:math.sin(bo_13) * :math.sin(be_13) * :math.cos(fo_1), :math.cos(be_13) - :math.sin(fo_1) * :math.sin(fo_3))
    la_3 = la_1 + diff_la_13

    [radians_to_degrees(fo_3), radians_to_degrees(la_3)]
  end

  defp rem_float(float_1, float_2) when float_1 < float_2 and float_1 < 0 and float_2 > 0 do
    rem_float(float_1 + float_2, float_2)
  end
  defp rem_float(float_1, float_2) when float_1 < float_2 and float_2 > 0 do
    float_1
  end
  defp rem_float(float_1, float_2) when float_2 > 0 do
    rem_float(float_1 - float_2, float_2)
  end

  @doc """
  Converts degrees to radians.
  Return radians.
  """
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

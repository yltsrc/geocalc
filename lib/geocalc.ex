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
  Finds point between start and end points in direction to end point with given distance.
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
  Finds point from start point with given distance and bearing.
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

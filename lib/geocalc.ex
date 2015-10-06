defmodule Geocalc do
  @earth_radius 6_371_000

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
    point_1_lat_rad = radian(point_1_lat)
    point_2_lat_rad = radian(point_2_lat)
    diff_lat = radian(point_2_lat - point_1_lat)
    diff_lng = radian(point_2_lng - point_1_lng)
    a = :math.sin(diff_lat / 2) * :math.sin(diff_lat / 2) + :math.cos(point_1_lat_rad) * :math.cos(point_2_lat_rad) * :math.sin(diff_lng / 2) * :math.sin(diff_lng / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  @doc """
  Calculates bearing.
  Return degrees from the range -180°..180°.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> london = [51.5286416, -0.1015987]
      iex> Geocalc.bearing(berlin, paris)
      15.113303075326261
      iex> Geocalc.bearing(paris, berlin)
      82.85424470451336
      iex> Geocalc.bearing(paris, london)
      -110.99076100695387
  """
  def bearing([point_1_lat, point_1_lng], [point_2_lat, point_2_lng]) do
    y = :math.sin(point_2_lng - point_1_lng) * :math.cos(point_2_lat)
    x = :math.cos(point_1_lat) * :math.sin(point_2_lat) - :math.sin(point_1_lat) * :math.cos(point_2_lat) * :math.cos(point_2_lng - point_1_lng)
    degrees(:math.atan2(y, x))
  end

  defp radian(lat_or_lng) do
    lat_or_lng * :math.pi / 180
  end

  defp degrees(radians) do
    radians * 180 / :math.pi
  end
end

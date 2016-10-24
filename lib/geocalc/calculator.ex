defmodule Geocalc.Calculator do
  @moduledoc ""

  use GenServer

  alias Geocalc.Point

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, []}
  end

  def handle_call({:distance_between, point_1, point_2}, _from, state) do
    {:reply, distance_between(point_1, point_2), state}
  end

  def handle_call({:bearing, point_1, point_2}, _from, state) do
    {:reply, bearing(point_1, point_2), state}
  end

  def handle_call({:destination_point, point_1, point_2, distance}, _from, state) do
    {:reply, destination_point(point_1, point_2, distance), state}
  end

  def handle_call({:intersection_point, point_1, bearing_1, point_2, bearing_2}, _from, state) do
    {:reply, intersection_point(point_1, bearing_1, point_2, bearing_2), state}
  end

  def handle_call({:degrees_to_radians, degrees}, _from, state) do
    {:reply, degrees_to_radians(degrees), state}
  end

  def handle_call({:radians_to_degrees, radians}, _from, state) do
    {:reply, radians_to_degrees(radians), state}
  end

  def handle_call({:bounding_box, point, radius_in_m}, _from, state) do
    {:reply, bounding_box(point, radius_in_m), state}
  end

  def handle_call({:geographic_center, points}, _from, state) do
    {:reply, geographic_center(points), state}
  end

  @earth_radius 6_371_000
  @pi :math.pi
  @intersection_not_found "No intersection point found"

  defp distance_between(point_1, point_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    diff_fo = degrees_to_radians(Point.latitude(point_2) - Point.latitude(point_1))
    diff_la = degrees_to_radians(Point.longitude(point_2) - Point.longitude(point_1))
    a = :math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) + :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  defp bearing(point_1, point_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    la_2 = degrees_to_radians(Point.longitude(point_2))
    y = :math.sin(la_2 - la_1) * :math.cos(fo_2)
    x = :math.cos(fo_1) * :math.sin(fo_2) - :math.sin(fo_1) * :math.cos(fo_2) * :math.cos(la_2 - la_1)
    :math.atan2(y, x)
  end

  defp destination_point(point_1, brng, distance) when is_number(brng)  do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    rad_lat = :math.asin(:math.sin(fo_1) * :math.cos(distance / @earth_radius) + :math.cos(fo_1) * :math.sin(distance / @earth_radius) * :math.cos(brng))
    rad_lng = la_1 + :math.atan2(:math.sin(brng) * :math.sin(distance / @earth_radius) * :math.cos(fo_1), :math.cos(distance / @earth_radius) - :math.sin(fo_1) * :math.sin(rad_lat))
    {:ok, [radians_to_degrees(rad_lat), radians_to_degrees(rad_lng)]}
  end
  defp destination_point(point_1, point_2, distance) do
    brng = bearing(point_1, point_2)
    destination_point(point_1, brng, distance)
  end

  defp intersection_point(point_1, bearing_1, point_2, bearing_2) when is_number(bearing_1) and is_number(bearing_2) do
    try do
      intersection_point!(point_1, bearing_1, point_2, bearing_2)
    catch
      message -> {:error, message}
    end
  end
  defp intersection_point(point_1, bearing_1, point_3, point_4) when is_number(bearing_1) do
    brng_3 = bearing(point_3, point_4)
    intersection_point(point_1, bearing_1, point_3, brng_3)
  end
  defp intersection_point(point_1, point_2, point_3, bearing_2) when is_number(bearing_2) do
    brng_1 = bearing(point_1, point_2)
    intersection_point(point_1, brng_1, point_3, bearing_2)
  end
  defp intersection_point(point_1, point_2, point_3, point_4) do
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
    {bo_12, bo_21} = if :math.sin(la_2 - la_1) > 0 do
      {bo_1, 2 * :math.pi - bo_2}
    else
      {2 * :math.pi - bo_1, bo_2}
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

  defp rem_float(float_1, float_2) when float_1 < 0 do
    float_1 - (Float.ceil(float_1 / float_2) * float_2)
  end
  defp rem_float(float_1, float_2) do
    float_1 - (Float.floor(float_1 / float_2) * float_2)
  end

  defp degrees_to_radians(degrees) do
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

  defp radians_to_degrees(radians) do
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

  def bounding_box(point, radius_in_m) do
    lat = degrees_to_radians(Point.latitude(point))
    lon = degrees_to_radians(Point.longitude(point))
    radius = earth_radius(lat)
    pradius = radius * :math.cos(lat)

    lat_min = lat - radius_in_m/radius
    lat_max = lat + radius_in_m/radius
    lon_min = lon - radius_in_m/pradius
    lon_max = lon + radius_in_m/pradius

    [
      [radians_to_degrees(lat_min), radians_to_degrees(lon_min)],
      [radians_to_degrees(lat_max), radians_to_degrees(lon_max)],
    ]
  end

  def geographic_center(points) do
    [xa, ya, za] =
      points
      |> Enum.map(fn (point) -> [degrees_to_radians(Point.latitude(point)), degrees_to_radians(Point.longitude(point))] end)
      |> Enum.reduce([[], [], []], fn (point, [x, y, z]) ->
          x = [:math.cos(Point.latitude(point)) * :math.cos(Point.longitude(point)) | x]
          y = [:math.cos(Point.latitude(point)) * :math.sin(Point.longitude(point)) | y]
          z = [:math.sin(Point.latitude(point)) | z]
          [x, y, z]
        end)
      |> Enum.map(fn (list) -> Enum.reduce(list, 0, fn (val, acc) -> acc + val end) / length(list) end)

    lon = :math.atan2(ya, xa)
    hyp = :math.sqrt(xa * xa + ya * ya)
    lat = :math.atan2(za, hyp)

    [radians_to_degrees(lat), radians_to_degrees(lon)]
  end

  # Semi-axes of WGS-84 geoidal reference
  @wgsa 6378137.0  # Major semiaxis [m]
  @wgsb 6356752.3  # Minor semiaxis [m]

  defp earth_radius(lat) do
    # http://en.wikipedia.org/wiki/Earth_radius
    an = @wgsa * @wgsa * :math.cos(lat)
    bn = @wgsb * @wgsb * :math.sin(lat)
    ad = @wgsa * :math.cos(lat)
    bd = @wgsb * :math.sin(lat)
    :math.sqrt( (an*an + bn*bn)/(ad*ad + bd*bd) )
  end
end

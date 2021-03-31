defmodule Geocalc.Calculator do
  @moduledoc false

  alias Geocalc.Point

  @earth_radius 6_371_000
  @pi :math.pi()
  @epsilon 2.220446049250313e-16
  @intersection_not_found "No intersection point found"

  def distance_between(point_1, point_2, radius \\ @earth_radius) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    diff_fo = degrees_to_radians(Point.latitude(point_2) - Point.latitude(point_1))
    diff_la = degrees_to_radians(Point.longitude(point_2) - Point.longitude(point_1))

    a =
      :math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) +
        :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    radius * c
  end

  def bearing(point_1, point_2) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    fo_2 = degrees_to_radians(Point.latitude(point_2))
    la_1 = degrees_to_radians(Point.longitude(point_1))
    la_2 = degrees_to_radians(Point.longitude(point_2))
    y = :math.sin(la_2 - la_1) * :math.cos(fo_2)

    x =
      :math.cos(fo_1) * :math.sin(fo_2) -
        :math.sin(fo_1) * :math.cos(fo_2) * :math.cos(la_2 - la_1)

    :math.atan2(y, x)
  end

  def destination_point(point_1, brng, distance) do
    destination_point(point_1, brng, distance, @earth_radius)
  end

  defp destination_point(point_1, brng, distance, radius) when is_number(brng) do
    fo_1 = degrees_to_radians(Point.latitude(point_1))
    la_1 = degrees_to_radians(Point.longitude(point_1))

    rad_lat =
      :math.asin(
        :math.sin(fo_1) * :math.cos(distance / radius) +
          :math.cos(fo_1) * :math.sin(distance / radius) * :math.cos(brng)
      )

    rad_lng =
      la_1 +
        :math.atan2(
          :math.sin(brng) * :math.sin(distance / radius) * :math.cos(fo_1),
          :math.cos(distance / radius) - :math.sin(fo_1) * :math.sin(rad_lat)
        )

    {:ok, [radians_to_degrees(rad_lat), radians_to_degrees(rad_lng)]}
  end

  defp destination_point(point_1, point_2, distance, radius) do
    brng = bearing(point_1, point_2)
    destination_point(point_1, brng, distance, radius)
  end

  def intersection_point(point_1, bearing_1, point_2, bearing_2)
      when is_number(bearing_1) and is_number(bearing_2) do
    intersection_point!(point_1, bearing_1, point_2, bearing_2)
  catch
    message -> {:error, message}
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

    # angular distance point_1 - point_2
    be_12 =
      2 *
        :math.asin(
          :math.sqrt(
            :math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) +
              :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)
          )
        )

    if abs(be_12) < @epsilon do
      {:ok, [Point.latitude(point_1), Point.longitude(point_1)]}
    else
      cos_fo_a =
        (:math.sin(fo_2) - :math.sin(fo_1) * :math.cos(be_12)) /
          (:math.sin(be_12) * :math.cos(fo_1))

      cos_fo_b =
        (:math.sin(fo_1) - :math.sin(fo_2) * :math.cos(be_12)) /
          (:math.sin(be_12) * :math.cos(fo_2))

      bo_1 = :math.acos(min(max(cos_fo_a, -1), 1))
      bo_2 = :math.acos(min(max(cos_fo_b, -1), 1))

      {bo_12, bo_21} =
        if :math.sin(la_2 - la_1) > 0 do
          {bo_1, 2 * :math.pi() - bo_2}
        else
          {2 * :math.pi() - bo_1, bo_2}
        end

      a_1 = bo_13 - bo_12
      a_2 = bo_21 - bo_23
      # infinite intersections
      if :math.sin(a_1) == 0 && :math.sin(a_2) == 0, do: throw(@intersection_not_found)
      # ambiguous intersection
      if :math.sin(a_1) * :math.sin(a_2) < 0, do: throw(@intersection_not_found)

      a_3 =
        :math.acos(
          -:math.cos(a_1) * :math.cos(a_2) + :math.sin(a_1) * :math.sin(a_2) * :math.cos(be_12)
        )

      be_13 =
        :math.atan2(
          :math.sin(be_12) * :math.sin(a_1) * :math.sin(a_2),
          :math.cos(a_2) + :math.cos(a_1) * :math.cos(a_3)
        )

      fo_3 =
        :math.asin(
          :math.sin(fo_1) * :math.cos(be_13) +
            :math.cos(fo_1) * :math.sin(be_13) * :math.cos(bo_13)
        )

      diff_la_13 =
        :math.atan2(
          :math.sin(bo_13) * :math.sin(be_13) * :math.cos(fo_1),
          :math.cos(be_13) - :math.sin(fo_1) * :math.sin(fo_3)
        )

      la_3 = la_1 + diff_la_13

      {:ok, [radians_to_degrees(fo_3), radians_to_degrees(la_3)]}
    end
  end

  def rem_float(float_1, float_2) when float_1 < 0 do
    float_1 - Float.ceil(float_1 / float_2) * float_2
  end

  def rem_float(float_1, float_2) do
    float_1 - Float.floor(float_1 / float_2) * float_2
  end

  def degrees_to_radians(degrees) do
    normalize_degrees(degrees) * :math.pi() / 180
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

  def radians_to_degrees(radians) do
    normalize_radians(radians) * 180 / :math.pi()
  end

  defp normalize_radians(radians) when radians < -@pi do
    normalize_radians(radians + 2 * :math.pi())
  end

  defp normalize_radians(radians) when radians > @pi do
    normalize_radians(radians - 2 * :math.pi())
  end

  defp normalize_radians(radians) do
    radians
  end

  def bounding_box(point, radius_in_m) do
    lat = degrees_to_radians(Point.latitude(point))
    lon = degrees_to_radians(Point.longitude(point))
    radius = earth_radius(lat)
    pradius = radius * :math.cos(lat)

    lat_min = lat - radius_in_m / radius
    lat_max = lat + radius_in_m / radius
    lon_min = lon - radius_in_m / pradius
    lon_max = lon + radius_in_m / pradius

    [
      [radians_to_degrees(lat_min), radians_to_degrees(lon_min)],
      [radians_to_degrees(lat_max), radians_to_degrees(lon_max)]
    ]
  end

  def bounding_box_for_points([]) do
    [[0, 0], [0, 0]]
  end

  def bounding_box_for_points([point]) do
    bounding_box(point, 0)
  end

  def bounding_box_for_points([point | points]) do
    extend_bounding_box(bounding_box(point, 0), bounding_box_for_points(points))
  end

  def extend_bounding_box([sw_point_1, ne_point_1], [sw_point_2, ne_point_2]) do
    sw_lat = Kernel.min(Point.latitude(sw_point_2), Point.latitude(sw_point_1))
    sw_lon = Kernel.min(Point.longitude(sw_point_2), Point.longitude(sw_point_1))
    ne_lat = Kernel.max(Point.latitude(ne_point_2), Point.latitude(ne_point_1))
    ne_lon = Kernel.max(Point.longitude(ne_point_2), Point.longitude(ne_point_1))

    [
      [sw_lat, sw_lon],
      [ne_lat, ne_lon]
    ]
  end

  def contains_point?([sw_point, ne_point], point) do
    Point.latitude(point) >= Point.latitude(sw_point) &&
      Point.latitude(point) <= Point.latitude(ne_point) &&
      Point.longitude(point) >= Point.longitude(sw_point) &&
      Point.longitude(point) <= Point.longitude(ne_point)
  end

  def intersects_bounding_box?([sw_point_1, ne_point_1], [sw_point_2, ne_point_2]) do
    Point.latitude(ne_point_2) >= Point.latitude(sw_point_1) &&
      Point.latitude(sw_point_2) <= Point.latitude(ne_point_1) &&
      Point.longitude(ne_point_2) >= Point.longitude(sw_point_1) &&
      Point.longitude(sw_point_2) <= Point.longitude(ne_point_1)
  end

  def overlaps_bounding_box?([sw_point_1, ne_point_1], [sw_point_2, ne_point_2]) do
    Point.latitude(ne_point_2) > Point.latitude(sw_point_1) &&
      Point.latitude(sw_point_2) < Point.latitude(ne_point_1) &&
      Point.longitude(ne_point_2) > Point.longitude(sw_point_1) &&
      Point.longitude(sw_point_2) < Point.longitude(ne_point_1)
  end

  # Semi-axes of WGS-84 geoidal reference
  # Major semiaxis [m]
  @wgsa 6_378_137.0
  # Minor semiaxis [m]
  @wgsb 6_356_752.3

  def earth_radius(lat) do
    # http://en.wikipedia.org/wiki/Earth_radius
    an = @wgsa * @wgsa * :math.cos(lat)
    bn = @wgsb * @wgsb * :math.sin(lat)
    ad = @wgsa * :math.cos(lat)
    bd = @wgsb * :math.sin(lat)
    :math.sqrt((an * an + bn * bn) / (ad * ad + bd * bd))
  end

  def geographic_center(points) do
    [xa, ya, za] =
      points
      |> Enum.map(fn point ->
        [degrees_to_radians(Point.latitude(point)), degrees_to_radians(Point.longitude(point))]
      end)
      |> Enum.reduce([[], [], []], fn point, [x, y, z] ->
        x = [:math.cos(Point.latitude(point)) * :math.cos(Point.longitude(point)) | x]
        y = [:math.cos(Point.latitude(point)) * :math.sin(Point.longitude(point)) | y]
        z = [:math.sin(Point.latitude(point)) | z]
        [x, y, z]
      end)
      |> Enum.map(fn list -> Enum.sum(list) / length(list) end)

    lon = :math.atan2(ya, xa)
    hyp = :math.sqrt(xa * xa + ya * ya)
    lat = :math.atan2(za, hyp)

    [radians_to_degrees(lat), radians_to_degrees(lon)]
  end

  def max_latitude(point, bearing) do
    lat = degrees_to_radians(Point.latitude(point))
    max_lat = :math.acos(Kernel.abs(:math.sin(bearing) * :math.cos(lat)))
    radians_to_degrees(max_lat)
  end

  def cross_track_distance_to(point, path_start_point, path_end_point, radius \\ @earth_radius) do
    dist_13 = distance_between(path_start_point, point, radius) / radius
    be_13 = bearing(path_start_point, point)
    be_12 = bearing(path_start_point, path_end_point)
    :math.asin(:math.sin(dist_13) * :math.sin(be_13 - be_12)) * radius
  end

  def along_track_distance_to(point, path_start_point, path_end_point, radius \\ @earth_radius) do
    dist_13 = distance_between(path_start_point, point, radius) / radius
    be_13 = bearing(path_start_point, point)
    be_12 = bearing(path_start_point, path_end_point)
    bo_xt = :math.asin(:math.sin(dist_13) * :math.sin(be_13 - be_12))
    bo_at = :math.acos(:math.cos(dist_13) / abs(:math.cos(bo_xt)))

    bo_at * sign(:math.cos(be_12 - be_13)) * radius
  end

  def crossing_parallels(point_1, point_2, latitude) do
    lat = degrees_to_radians(latitude)

    lat_1 = degrees_to_radians(Point.latitude(point_1))
    lon_1 = degrees_to_radians(Point.longitude(point_1))
    lat_2 = degrees_to_radians(Point.latitude(point_2))
    lon_2 = degrees_to_radians(Point.longitude(point_2))

    diff_lon = lon_2 - lon_1

    x = :math.sin(lat_1) * :math.cos(lat_2) * :math.cos(lat) * :math.sin(diff_lon)

    y =
      :math.sin(lat_1) * :math.cos(lat_2) * :math.cos(lat) * :math.cos(diff_lon) -
        :math.cos(lat_1) * :math.sin(lat_2) * :math.cos(lat)

    z = :math.cos(lat_1) * :math.cos(lat_2) * :math.sin(lat) * :math.sin(diff_lon)

    if z * z > x * x + y * y do
      {:error, "Not found"}
    else
      lon_max = :math.atan2(-y, x)
      diff_lon_i = :math.acos(z / :math.sqrt(x * x + y * y))
      lon_i_1 = lon_1 + lon_max - diff_lon_i
      lon_i_2 = lon_1 + lon_max + diff_lon_i

      {:ok, rem_float(radians_to_degrees(lon_i_1) + 540, 360) - 180,
       rem_float(radians_to_degrees(lon_i_2) + 540, 360) - 180}
    end
  end

  defp sign(int) when int >= 0, do: 1
  defp sign(int) when int < 0, do: -1
end

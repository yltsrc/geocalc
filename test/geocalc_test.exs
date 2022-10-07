defmodule GeocalcTest do
  use ExUnit.Case
  doctest Geocalc

  alias Geocalc.{Point, Shape}

  test "calculates distance between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.distance_between(point_1, point_2), 968_853.5, 0.05
  end

  test "calculates distance between two decimal points" do
    point_1 = [Decimal.new("50.0663889"), Decimal.new("-5.7147222")]
    point_2 = [Decimal.new("58.6438889"), Decimal.new("-3.07")]
    assert_in_delta Geocalc.distance_between(point_1, point_2), 968_853.5, 0.05
  end

  test "returns true when point is within a given radius from the circle center" do
    center = [18.2208, 66.5901]
    point = [18.4655, 66.1057]
    assert Geocalc.within?(170_000, center, point)
  end

  test "returns true when radius is 0 and the point equals the center point" do
    center = [18.2208, 66.5901]
    assert Geocalc.within?(0, center, center)
  end

  test "returns false when radius is 0 and point does not equal center point" do
    center = [18.2208, 66.5901]
    point = [18.4655, 66.1057]
    refute Geocalc.within?(0, center, point)
  end

  test "returns false when point is not wihtin a given radius from the circle center" do
    center = [18.2208, 66.5901]
    point = [52.5075419, 13.4251364]
    refute Geocalc.within?(170_000, center, point)
  end

  test "returns false when radius is negative" do
    center = [18.2208, 66.5901]
    point = [52.5075419, 13.4251364]
    refute Geocalc.within?(-170_000, center, point)
  end

  test "calculates distance between Minsk and London" do
    minsk = %{lat: 53.8838884, lon: 27.5949741}
    london = %{lat: Decimal.new("51.5286416"), lon: Decimal.new("-0.1015987")}
    assert_in_delta Geocalc.distance_between(minsk, london), 1_872_028.5, 0.05
  end

  test "calculates bearing between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.bearing(point_1, point_2), 0.159170, 0.000001
  end

  test "calculates bearing between Minsk and London" do
    minsk = %{latitude: 53.8838884, longitude: 27.5949741}
    london = %{latitude: Decimal.new("51.5286416"), longitude: Decimal.new("-0.1015987")}
    assert_in_delta Geocalc.bearing(minsk, london), -1.513836, 0.000001
  end

  test "returns destination point between two points in direction to second point" do
    point_1 = [1.234, 2.345]
    point_2 = [3.654, 4.765]
    distance = 1_000
    brng = Geocalc.bearing(point_1, point_2)
    {:ok, point_3} = Geocalc.destination_point(point_1, brng, distance)

    assert_in_delta Geocalc.distance_between(point_3, [1.2403670648864074, 2.3513527343464733]),
                    0,
                    0.0005

    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns destination point in pacific ocean near Japan" do
    point_1 = %{lat: 46.118942, lng: 150.402832}
    point_2 = %{lat: 21.913108, lng: -160.193712}
    distance = 1_178_348
    {:ok, point_3} = Geocalc.destination_point(point_1, point_2, distance)

    assert_in_delta Geocalc.distance_between(point_3, [42.64962243973242, 164.43934677825277]),
                    0,
                    0.0005

    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns destination point in pacific ocean near Hawaii" do
    point_1 = {46.118942, 150.402832}
    point_2 = {Decimal.new("21.913108"), Decimal.new("-160.193712")}
    distance = 4_178_348
    {:ok, point_3} = Geocalc.destination_point(point_1, point_2, distance)

    assert_in_delta Geocalc.distance_between(point_3, [27.939238854720823, -167.5615280845497]),
                    0,
                    0.0005

    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns intersection point" do
    point_1 = [51.8853, 0.2545]
    bearing_1 = Geocalc.degrees_to_radians(108.547)
    point_2 = [49.0034, 2.5735]
    bearing_2 = Geocalc.degrees_to_radians(32.435)
    {:ok, point_3} = Geocalc.intersection_point(point_1, bearing_1, point_2, bearing_2)
    assert_in_delta Point.latitude(point_3), 50.9078, 0.00001
    assert_in_delta Point.longitude(point_3), 4.5084, 0.00001
  end

  test "all roads lead to Rome" do
    milan = {45.4628328, 9.1076929}
    naples = {40.8536668, 14.2079876}
    rome = {41.9102415, 12.3959161}
    {:ok, point_3} = Geocalc.intersection_point(milan, rome, naples, rome)
    assert_in_delta Geocalc.distance_between(point_3, rome), 0, 0.0005
  end

  test "returns point if point 1 and point 2 are the same" do
    minsk = %{lat: 53.8838884, lon: 27.5949741}
    bearing = Geocalc.degrees_to_radians(0)
    {:ok, point} = Geocalc.intersection_point(minsk, bearing, minsk, bearing)
    assert Point.latitude(point) == Point.latitude(minsk)
    assert Point.longitude(point) == Point.longitude(minsk)
  end

  test "returns error message if intersection point not found" do
    point_1 = %{lat: 0, lon: 30}
    point_2 = %{lat: 0, lon: 60}
    bearing_1 = Geocalc.degrees_to_radians(0)
    bearing_2 = Geocalc.degrees_to_radians(90)
    {:error, msg} = Geocalc.intersection_point(point_1, bearing_1, point_2, bearing_2)
    assert msg == "No intersection point found"
  end

  test "crashes with ArithmeticError" do
    point_1 = %{lat: 30, lon: 0}
    point_2 = %{lat: 60, lon: 0}
    bearing = Geocalc.degrees_to_radians(90)
    {:ok, point} = Geocalc.intersection_point(point_1, bearing, point_2, bearing)
    assert_in_delta Geocalc.distance_between(point, [0, 90]), 0, 0.0005
  end

  test "returns error message for two perpendicular destinations" do
    point = %{lat: 0, lon: 0}
    bearing_1 = Geocalc.degrees_to_radians(0)
    bearing_2 = Geocalc.degrees_to_radians(90)
    {:ok, point} = Geocalc.intersection_point(point, bearing_1, point, bearing_2)
    assert_in_delta Geocalc.distance_between(point, [0, 0]), 0, 0.0005
  end

  test "returns a bounding box given a point and a radius in meters" do
    point = [52.5075419, 13.4251364]
    radius = 10_000

    assert Geocalc.bounding_box(point, radius) == [
             [52.417520954378574, 13.277235453275123],
             [52.59756284562143, 13.573037346724874]
           ]
  end

  test "returns a bounding box given a list of points" do
    point_1 = %{lat: 46.118942, lng: 150.402832}
    point_2 = %{lat: 21.913108, lng: -160.193712}

    assert Geocalc.bounding_box_for_points([point_1, point_2]) == [
             [21.913108000000005, -160.193712],
             [46.118942, 150.402832]
           ]
  end

  test "returns an extended bounding box" do
    london = [51.5286416, -0.1015987]
    paris = [48.8588589, 2.3475569]

    assert Geocalc.extend_bounding_box([london, london], [paris, paris]) == [
             [48.8588589, -0.1015987],
             [51.5286416, 2.3475569]
           ]
  end

  test "returns true if bounding box contains point" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    paris = [48.8588589, 2.3475569]

    assert Geocalc.contains_point?(france, paris)
  end

  test "returns false if bounding box does not contains point" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    london = [51.5286416, -0.1015987]

    refute Geocalc.contains_point?(france, london)
  end

  test "returns true if bounding box intersects bounding box" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    spain = [[27.43, -18.39], [43.99, 4.59]]

    assert Geocalc.intersects_bounding_box?(france, spain)
  end

  test "returns true if bounding box intersects bounding box with one point in common" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    border = [[51.2, -5.22], [52, -5]]

    assert Geocalc.intersects_bounding_box?(france, border)
  end

  test "returns false if bounding box does not intersects bounding box" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    portugal = [[29.83, -31.56], [42.15, -6.19]]

    refute Geocalc.intersects_bounding_box?(france, portugal)
  end

  test "returns true if bounding box overlaps bounding box" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    spain = [[27.43, -18.39], [43.99, 4.59]]

    assert Geocalc.overlaps_bounding_box?(france, spain)
  end

  test "returns false if bounding box overlaps bounding box with one point in common" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    border = [[51.2, -5.22], [52, -5]]

    refute Geocalc.overlaps_bounding_box?(france, border)
  end

  test "returns false if bounding box does not overlaps bounding box" do
    france = [[41.33, -5.22], [51.2, 9.55]]
    portugal = [[29.83, -31.56], [42.15, -6.19]]

    refute Geocalc.overlaps_bounding_box?(france, portugal)
  end

  test "returns a bounding box given a list with one point" do
    point = [52.5075419, 13.4251364]

    assert Geocalc.bounding_box_for_points([point]) == [
             point,
             point
           ]
  end

  test "returns a bounding box given a list with no points" do
    assert Geocalc.bounding_box_for_points([]) == [[0, 0], [0, 0]]
  end

  test "returns geographic center point" do
    assert Geocalc.geographic_center([[0, 0], [0, 1]]) == [0.0, 0.5]
    assert Geocalc.geographic_center([[0, 0], [0, 1], [0, 2]]) == [0.0, 1.0]
  end

  test "returns max latitude" do
    bearing_1 = Geocalc.degrees_to_radians(0)
    bearing_2 = Geocalc.degrees_to_radians(90)
    assert Geocalc.max_latitude([0, 0], bearing_1) == 90.0
    assert Geocalc.max_latitude([0, 0], bearing_2) == 0.0
  end

  test "returns cross track distance to point" do
    point_1 = %{lat: 53.2611, lng: -0.7972}
    point_2 = %{lat: 53.3206, lng: -1.7297}
    point_3 = %{lat: 53.1887, lng: 0.1334}
    assert_in_delta Geocalc.cross_track_distance_to(point_1, point_2, point_3), -307.5, 0.05
  end

  test "returns along track distance to point" do
    point_1 = %{lat: 53.2611, lng: -0.7972}
    point_2 = %{lat: 53.3206, lng: -1.7297}
    point_3 = %{lat: 53.1887, lng: 0.1334}
    assert_in_delta Geocalc.along_track_distance_to(point_1, point_2, point_3), 62_331, 0.5
  end

  test "returns crossing parallels" do
    point_1 = %{lat: 46.1189424, lng: 150.402832}
    point_2 = %{lat: 21.9131082, lng: -160.1937128}
    latitude = 45.0

    assert Geocalc.crossing_parallels(point_1, point_2, latitude) ==
             {:ok, 106.52361930066911, 155.95500236778838}
  end

  test "returns error message if no crossing parallels found" do
    point_1 = %{lat: 0, lng: 0}
    point_2 = %{lat: 180, lng: 90}
    latitude = 45.0
    assert Geocalc.crossing_parallels(point_1, point_2, latitude) == {:error, "Not found"}
  end

  test "returns if point is inside circle area" do
    area = %Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 1000}
    point = %{lat: 48.856612, lng: 2.3522217}

    assert Geocalc.in_area?(area, point)
    assert not Geocalc.outside_area?(area, point)
    assert not Geocalc.at_area_border?(area, point)
    assert not Geocalc.at_center_point?(area, point)
  end

  test "returns if point is at center of a circle area" do
    area = %Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 10}
    point = %{lat: 48.856614, lng: 2.3522219}

    assert Geocalc.in_area?(area, point)
    assert Geocalc.at_center_point?(area, point)
  end

  test "returns if point is at border of circle area" do
    area = %Shape.Circle{latitude: 48.856614, longitude: 2.3522219, radius: 1000}
    point = %{lat: 48.856418, lng: 2.365871}

    assert Geocalc.at_area_border?(area, point)
  end

  test "returns if point is inside rectangle area" do
    area = %Shape.Rectangle{
      latitude: 48.856614,
      longitude: 2.3522219,
      long_semi_axis: 500,
      short_semi_axis: 250,
      angle: 0
    }

    point = %{lat: 48.856612, lng: 2.3522217}

    assert Geocalc.in_area?(area, point)
    assert not Geocalc.outside_area?(area, point)
    assert not Geocalc.at_area_border?(area, point)
    assert not Geocalc.at_center_point?(area, point)
  end

  test "returns if point is inside ellipse area" do
    area = %Shape.Ellipse{
      latitude: 48.856614,
      longitude: 2.3522219,
      long_semi_axis: 500,
      short_semi_axis: 250,
      angle: 0
    }

    point = %{lat: 48.856612, lng: 2.3522217}

    assert Geocalc.in_area?(area, point)
    assert not Geocalc.outside_area?(area, point)
    assert not Geocalc.at_area_border?(area, point)
    assert not Geocalc.at_center_point?(area, point)
  end
end

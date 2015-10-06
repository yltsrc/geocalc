defmodule GeocalcTest do
  use ExUnit.Case

  test "calculates distance between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.distance_between(point_1, point_2), 968_853.5, 0.05
  end

  test "calculates distance between Minsk and London" do
    minsk = [53.8838884, 27.5949741]
    london = [51.5286416, -0.1015987]
    assert_in_delta Geocalc.distance_between(minsk, london), 1_872_028.5, 0.05
  end

  test "calculates bearing between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.bearing(point_1, point_2), 0.159170, 0.000001
  end

  test "calculates bearing between Minsk and London" do
    minsk = [53.8838884, 27.5949741]
    london = [51.5286416, -0.1015987]
    assert_in_delta Geocalc.bearing(minsk, london), -1.513836, 0.000001
  end

  test "calculates point between two points in direction to second point" do
    point_1 = [1.234, 2.345]
    point_2 = [3.654, 4.765]
    distance = 1_000
    point_3 = Geocalc.destination_point_given_distance_from_start_and_end_point(point_1, point_2, distance)
    assert_in_delta Geocalc.distance_between(point_3, [1.2403670648864074, 2.3513527343464733]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns point in pacific ocean near Japan" do
    point_1 = [46.118942, 150.402832]
    point_2 = [21.913108, -160.193712]
    distance = 1_178_348
    point_3 = Geocalc.destination_point_given_distance_from_start_and_end_point(point_1, point_2, distance)
    assert_in_delta Geocalc.distance_between(point_3, [42.64962243973242, 164.43934677825277]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns point in pacific ocean near Hawaii" do
    point_1 = [46.118942, 150.402832]
    point_2 = [21.913108, -160.193712]
    distance = 4_178_348
    point_3 = Geocalc.destination_point_given_distance_from_start_and_end_point(point_1, point_2, distance)
    assert_in_delta Geocalc.distance_between(point_3, [27.939238854720823, -167.5615280845497]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end
end

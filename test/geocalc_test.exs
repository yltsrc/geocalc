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
end

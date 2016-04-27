defmodule GeocalcBench do
  @moduledoc """
  ## Run benchmarks
  ```sh-session
  $ mix deps.get
  $ MIX_ENV=bench mix compile
  $ MIX_ENV=bench mix bench
  ```
  """

  use Benchfella

  bench "degrees to radians" do
    Geocalc.degrees_to_radians(555)
  end

  bench "radians to degrees" do
    Geocalc.radians_to_degrees(-5.12)
  end

  @berlin %{lat: 52.5075419, lon: 13.4251364}
  @london %{lat: 51.5286416, lng: -0.1015987}
  @paris %{lat: 48.8588589, lng: 2.3475569}
  @bearing Geocalc.bearing(@berlin, @paris)

  bench "distance between" do
    Geocalc.distance_between(@berlin, @london)
  end

  bench "bearing" do
    Geocalc.bearing(@berlin, @paris)
  end

  bench "destination point" do
    Geocalc.destination_point(@berlin, @bearing, 1_000_000)
  end

  bench "intersection point" do
    Geocalc.intersection_point(@berlin, @bearing, @london, 1.502)
  end
end

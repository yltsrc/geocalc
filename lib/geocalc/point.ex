defprotocol Geocalc.Point do
  @moduledoc """
    The `Geocalc.Point` protocol is responsible for receiving
    latitude and longitude from any Elixir data structure.
    At this time it have implementations only for Map, Tuple and List.
  """

  @doc "Returns point latitude"
  def latitude(point)

  @doc "Returns point longitude"
  def longitude(point)
end

defimpl Geocalc.Point, for: List do
  def latitude([lat, _lng]), do: lat
  def longitude([_lat, lng]), do: lng
end

defimpl Geocalc.Point, for: Map do
  def latitude(%{lat: val}), do: val
  def latitude(%{latitude: val}), do: val
  def longitude(%{lon: val}), do: val
  def longitude(%{lng: val}), do: val
  def longitude(%{longitude: val}), do: val
end

defimpl Geocalc.Point, for: Tuple do
  def latitude({lat, _lng}), do: lat
  def longitude({_lat, lng}), do: lng
end

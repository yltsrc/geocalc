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
  def latitude([lat, _lng]) when is_number(lat) do
    lat
  end

  def longitude([_lat, lng]) when is_number(lng) do
    lng
  end
end

defimpl Geocalc.Point, for: Map do
  def latitude(%{lat: val}) when is_number(val) do
    val
  end
  def latitude(%{latitude: val}) when is_number(val) do
    val
  end

  def longitude(%{lon: val}) when is_number(val) do
    val
  end
  def longitude(%{lng: val}) when is_number(val) do
    val
  end
  def longitude(%{longitude: val}) when is_number(val) do
    val
  end
end

defimpl Geocalc.Point, for: Tuple do
  def latitude({lat, _lng}) when is_number(lat) do
    lat
  end
  def latitude({:ok, lat, _lng}) when is_number(lat) do
    lat
  end

  def longitude({_lat, lng}) when is_number(lng) do
    lng
  end
  def longitude({:ok, _lat, lng}) when is_number(lng) do
    lng
  end
end

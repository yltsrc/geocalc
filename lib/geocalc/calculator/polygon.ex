defmodule Geocalc.Calculator.Polygon do
  @moduledoc false

  alias Geocalc.Calculator
  require Integer

  @doc """
  Check if point is inside a polygon

  ## Example
      iex> import Geocalc.Calculator.Polygon
      iex> polygon = [[1, 2], [3, 4], [5, 2], [3, 0]]
      iex> point = [3, 2]
      iex> point_in_polygon?(polygon, point)
      true

  ## Example
      iex> import Geocalc.Calculator.Polygon
      iex> polygon = [[1, 2], [3, 4], [5, 2], [3, 0]]
      iex> point = [1.5, 3]
      iex> point_in_polygon?(polygon, point)
      false

  """
  def point_in_polygon?(polygon, point) do
    polygon
    |> point_in_bounding_box?(point)
    |> point_in_polygon?(polygon, point)
  end

  def point_in_polygon?(false, _polygon, _point), do: false

  def point_in_polygon?(true, polygon, point) do
    polygon
    |> to_segments()
    |> Enum.reduce(0, fn segment, count ->
      apply(__MODULE__, :ray_intersects_segment, add_epsilon(segment, point)) + count
    end)
    |> Integer.is_odd()
  end

  def to_segments([p1 | _] = polygon) do
    polygon |> Enum.chunk_every(2, 1, [p1]) |> Enum.map(fn segment -> orient_segment(segment) end)
  end

  def orient_segment([a = [_ax, ay], b = [_bx, by]]) when by >= ay do
    [a, b]
  end

  def orient_segment([b, a]) do
    [a, b]
  end

  def add_epsilon(segment = [[_ax, ay], [_bx, by]], [px, py]) when py == ay or py == by do
    [segment, [px, py + 0.00000001]]
  end

  def add_epsilon(segment, point), do: [segment, point]

  def ray_intersects_segment([[_ax, ay], [_bx, by]], [_px, py]) when py < ay or py > by do
    0
  end

  # px >= max(ax, bx)
  def ray_intersects_segment([[ax, _ay], [bx, _by]], [px, _py])
      when (ax >= bx and px >= ax) or (bx >= ax and px >= bx) do
    0
  end

  # px < min(ax, bx)
  def ray_intersects_segment([[ax, _ay], [bx, _by]], [px, _py])
      when (ax <= bx and px < ax) or (bx <= ax and px < bx) do
    1
  end

  def ray_intersects_segment([[ax, ay], [bx, by]], [px, py]) do
    m_red = m_red(ax, ay, bx, by)
    m_blue = m_blue(ax, ay, px, py)

    case {m_blue, m_red} do
      {:infinity, _} ->
        1

      {_, :infinity} ->
        0

      {m_blue, m_red} when m_blue >= m_red ->
        1

      _ ->
        0
    end
  end

  def m_red(ax, ay, bx, by) when ax != bx do
    (by - ay) / (bx - ax)
  end

  def m_red(_, _, _, _) do
    :infinity
  end

  def m_blue(ax, ay, px, py) when ax != px do
    (py - ay) / (px - ax)
  end

  def m_blue(_, _, _, _) do
    :infinity
  end

  def point_in_bounding_box?(polygon, point) do
    polygon
    |> Calculator.bounding_box_for_points()
    |> Calculator.contains_point?(point)
  end
end

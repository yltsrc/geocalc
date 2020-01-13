defmodule Geocalc.DMS do
  @moduledoc """
    The `Geocalc.DMS` is a struct which contains degrees, minutes, seconds and cardinal direction.
    Also have functions to convert DMS to decimal degrees.
  """

  @enforce_keys [:hours, :minutes, :seconds, :direction]
  defstruct [:hours, :minutes, :seconds, :direction]

  @type t :: %Geocalc.DMS{}

  @doc """
  Converts `Geocalc.DMS` to decimal degrees

  ## Example
      iex> dms = %Geocalc.DMS{hours: 13, minutes: 31, seconds: 59.998, direction: "N"}
      iex> Geocalc.DMS.to_decimal(dms)
      13.533332777777778
  """
  @spec to_decimal(Geocalc.DMS.t()) :: number | :error
  def to_decimal(%Geocalc.DMS{minutes: minutes}) when is_integer(minutes) and minutes >= 60 do
    :error
  end
  def to_decimal(%Geocalc.DMS{minutes: minutes}) when is_integer(minutes) and minutes < 0 do
    :error
  end

  def to_decimal(%Geocalc.DMS{seconds: seconds}) when is_number(seconds) and seconds >= 60 do
    :error
  end
  def to_decimal(%Geocalc.DMS{seconds: seconds}) when is_number(seconds) and seconds < 0 do
    :error
  end

  def to_decimal(%Geocalc.DMS{hours: hours, direction: "N"}) when is_integer(hours) and hours > 90 do
    :error
  end
  def to_decimal(%Geocalc.DMS{hours: hours, direction: "N"}) when is_integer(hours) and hours < -90 do
    :error
  end
  def to_decimal(%Geocalc.DMS{hours: hours, minutes: minutes, seconds: seconds, direction: "N"}) do
    hours + minutes / 60 + seconds / 3600
  end

  def to_decimal(%Geocalc.DMS{hours: hours, direction: "S"}) when is_integer(hours) and hours > 90 do
    :error
  end
  def to_decimal(%Geocalc.DMS{hours: hours, direction: "S"}) when is_integer(hours) and hours < -90 do
    :error
  end
  def to_decimal(%Geocalc.DMS{hours: hours, minutes: minutes, seconds: seconds, direction: "S"}) do
    -(hours + minutes / 60 + seconds / 3600)
  end

  def to_decimal(%Geocalc.DMS{hours: hours, minutes: minutes, seconds: seconds, direction: "W"}) do
    -(longitude_hours(hours) + minutes / 60 + seconds / 3600)
  end

  def to_decimal(%Geocalc.DMS{hours: hours, minutes: minutes, seconds: seconds, direction: "E"}) do
    longitude_hours(hours) + minutes / 60 + seconds / 3600
  end

  defp longitude_hours(hours) when is_integer(hours) and hours > 180 do
    longitude_hours(hours - 360)
  end
  defp longitude_hours(hours) when is_integer(hours) and hours < -180 do
    longitude_hours(hours + 360)
  end
  defp longitude_hours(hours) when is_integer(hours) do
    hours
  end
end

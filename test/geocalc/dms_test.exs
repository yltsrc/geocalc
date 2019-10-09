defmodule Geocalc.DMSTest do
  use ExUnit.Case
  alias Geocalc.DMS

  test "converts DMS to decimal" do
    dms = %DMS{hours: 3, minutes: 2, seconds: 1, direction: "N"}
    assert_in_delta DMS.to_decimal(dms), 3.03361, 0.000005
  end

  test "converts DMS with negative hours" do
    dms = %DMS{hours: -6, minutes: 2, seconds: 1, direction: "E"}
    assert_in_delta DMS.to_decimal(dms), -5.96639, 0.000005
  end

  test "converts DMS longitude hours" do
    dms = %DMS{hours: 363, minutes: 2, seconds: 1, direction: "W"}
    assert_in_delta DMS.to_decimal(dms), -3.03361, 0.000005
  end

  test "returns error if dms hours are not valid" do
    dms = %DMS{hours: 93, minutes: 2, seconds: 1, direction: "S"}
    assert DMS.to_decimal(dms) == :error
  end

  test "returns error if dms minutes are not valid" do
    dms = %DMS{hours: 93, minutes: -1, seconds: 1, direction: "S"}
    assert DMS.to_decimal(dms) == :error
  end

  test "returns error if dms seconds are not valid" do
    dms = %DMS{hours: 93, minutes: 61, seconds: 1, direction: "S"}
    assert DMS.to_decimal(dms) == :error
  end
end

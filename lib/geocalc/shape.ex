defmodule Geocalc.Shape do
  @moduledoc """
    `Geocalc.Shape` contains `Circle`, `Rectangle` and `Ellipse` shapes.
    Those shapes define a geographical area projection and are designed to be used for geofencing,
    ie: the user can determine if one point is inside or outside a geographical zone.
    Geographical zones are defined with a center point and several spatial dimensions (see each shape documentation)
  """

  defmodule Circle do
    @moduledoc """
      `Circle` describes a circular geographical area, centered on `latitude`, `longitude`,
      with a `radius` in meters. `latitude` and `longitude` could be decimal degrees or `Geocalc.DMS`.
    """
    @enforce_keys [:latitude, :longitude, :radius]
    defstruct [:latitude, :longitude, :radius]

    @type t :: %__MODULE__{
      latitude: number | Geocalc.DMS.t(),
      longitude: number | Geocalc.DMS.t(),
      radius: number
    }
  end

  defmodule Rectangle do
    @moduledoc """
      `Rectangle` describes a rectangular geographical area, centered on `latitude`, `longitude` (could be decimal degrees or `Geocalc.DMS`),
      with `long_semi_axis` and `short_semi_axis` (both in meters) and an azimuth `angle` (in degrees).
      `long_semi_axis` is the distance between the center point and the short side of the rectangle.
      `short_semi_axis` is the distance between the center point and the long side of the rectangle.
      `angle` is the azimuth angle of the long side of the rectangle, ie: the angle between north and `long_semi_axis`.
    """
    @enforce_keys [:latitude, :longitude, :long_semi_axis, :short_semi_axis, :angle]
    defstruct [:latitude, :longitude, :long_semi_axis, :short_semi_axis, :angle]

    @type t :: %__MODULE__{
      latitude: number | Geocalc.DMS.t(),
      longitude: number | Geocalc.DMS.t(),
      long_semi_axis: number,
      short_semi_axis: number,
      angle: number
    }
  end

  defmodule Ellipse do
    @moduledoc """
      `Ellipse` describes an elliptic geographical area, centered on `latitude`, `longitude` (could be decimal degrees or `Geocalc.DMS`),
      with `long_semi_axis` and `short_semi_axis` (both in meters) and an azimuth `angle` (in degrees).
      `long_semi_axis` is the length of the longest diameter, also called semi-major axis.
      `short_semi_axis` is the length of the shortest diameter, also called semi-minor axis.
      `angle` is the azimuth angle of the long semi-axis.
    """
    @enforce_keys [:latitude, :longitude, :long_semi_axis, :short_semi_axis, :angle]
    defstruct [:latitude, :longitude, :long_semi_axis, :short_semi_axis, :angle]

    @type t :: %__MODULE__{
      latitude: number | Geocalc.DMS.t(),
      longitude: number | Geocalc.DMS.t(),
      long_semi_axis: number,
      short_semi_axis: number,
      angle: number
    }
  end
end

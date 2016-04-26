defmodule Geocalc.Sup do
  @moduledoc ""

  use Supervisor

  alias Geocalc.Calculator

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(initial_value) do
    children = [
      worker(Calculator, initial_value, [])
    ]
    attrs = [strategy: :one_for_one, max_restarts: 1_000, max_seconds: 1]
    supervise(children, attrs)
  end
end

defmodule Geocalc.Supervisor do
  @moduledoc false

  alias Geocalc.Calculator

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    children = [
      # Starts a worker by calling:
      # Geocalc.Calculator.start_link()
      worker(Calculator, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, max_restarts: 1_000, max_seconds: 1]
    supervise(children, opts)
  end
end
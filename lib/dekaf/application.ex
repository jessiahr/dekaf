defmodule Dekaf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Dekaf.ClusterStatus, []}
    ]

    Logger.info("Starting Dekaf")
    opts = [strategy: :one_for_one, name: Dekaf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

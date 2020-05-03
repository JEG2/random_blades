defmodule RandomBlades.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RandomBladesWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RandomBlades.PubSub},
      # Start the Endpoint (http/https)
      RandomBladesWeb.Endpoint
      # Start a worker by calling: RandomBlades.Worker.start_link(arg)
      # {RandomBlades.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RandomBlades.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RandomBladesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

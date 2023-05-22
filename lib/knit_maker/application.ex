defmodule KnitMaker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: KnitMaker.KnittingRegistry},
      KnitMaker.KnittingSupervisor,
      # Start the Telemetry supervisor
      KnitMakerWeb.Telemetry,
      # Start the Ecto repository
      KnitMaker.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: KnitMaker.PubSub},
      # presence
      KnitMakerWeb.Presence,
      # Start the Endpoint (http/https)
      KnitMakerWeb.Endpoint
      # Start a worker by calling: KnitMaker.Worker.start_link(arg)
      # {KnitMaker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KnitMaker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KnitMakerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

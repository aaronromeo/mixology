defmodule Mixology.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Dotenv.load()
    Mix.Task.run("loadconfig")

    children = [
      # Start the Ecto repository
      Mixology.Repo,
      # Start the Telemetry supervisor
      MixologyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mixology.PubSub},
      # Start the Endpoint (http/https)
      MixologyWeb.Endpoint
      # Start a worker by calling: Mixology.Worker.start_link(arg)
      # {Mixology.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mixology.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MixologyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

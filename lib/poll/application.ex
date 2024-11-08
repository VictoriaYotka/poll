defmodule Poll.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PollWeb.Telemetry,
      Poll.Repo,
      {DNSCluster, query: Application.get_env(:poll, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Poll.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Poll.Finch},
      # Start a worker by calling: Poll.Worker.start_link(arg)
      # {Poll.Worker, arg},
      # Start to serve requests, typically the last entry
      PollWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Poll.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PollWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

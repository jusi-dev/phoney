defmodule Phoney.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoneyWeb.Telemetry,
      Phoney.Repo,
      {DNSCluster, query: Application.get_env(:phoney, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Phoney.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Phoney.Finch},
      # Start a worker by calling: Phoney.Worker.start_link(arg)
      # {Phoney.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoneyWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :phoney]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phoney.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoneyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

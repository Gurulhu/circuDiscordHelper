defmodule Lobotomist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Lobotomist.Worker.start_link(arg)
      # {Lobotomist.Worker, arg}
      Lobotomist.Consumer,
      {Finch, name: LobotomistFinch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lobotomist.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

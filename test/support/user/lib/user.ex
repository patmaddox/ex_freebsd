defmodule User do
  defmodule Application do
    use Elixir.Application

    @impl true
    def start(_type, _args) do
      children = [User.Worker]

      opts = [strategy: :one_for_one, name: User.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end

  defmodule Worker do
    use GenServer
    require Logger

    def start_link(args), do: GenServer.start_link(__MODULE__, args)

    def init(_) do
      :timer.send_interval(1_000, :tick)
      {:ok, nil}
    end

    def handle_info(:tick, state) do
      Logger.info("tick")
      {:noreply, state}
    end
  end
end

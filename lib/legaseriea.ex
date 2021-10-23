defmodule LegaSerieA do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_schedule(pid, team) do
    GenServer.call(pid, {:get_schedule, team})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get_schedule, team}, _from, _state) do
    res =
      LegaSerieA.Parser.round_urls()
      |> Enum.map(fn url ->
        Task.async(fn ->
          LegaSerieA.Parser.find_match_by_team(url, team) |> LegaSerieA.Parser.match_details()
        end)
      end)
      |> Task.await_many()

    {:reply, res, res}
  end
end

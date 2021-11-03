defmodule Venezia.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_match_details(pid, url, team) do
    GenServer.call(pid, {:get_match_details, url, team})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get_match_details, url, team}, _from, _state) do
    result = LegaSerieA.Parser.find_match_by_team(url, team) |> LegaSerieA.Parser.match_details()
    {:reply, result, nil}
  end
end

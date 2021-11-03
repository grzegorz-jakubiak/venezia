defmodule Venezia.Schedule do
  alias :poolboy, as: Poolboy

  @timeout 10000

  def get_schedule(team) do
    LegaSerieA.Parser.round_urls()
    |> Enum.map(fn url -> async_get_match_details(url, team) end)
    |> Enum.each(fn task -> await_and_inspect(task) end)
  end

    defp async_get_match_details(url, team) do
    Task.async(fn ->
      Poolboy.transaction(
        :worker,
        fn pid ->
          # Let's wrap the genserver call in a try - catch block. This allows us to trap any exceptions
          # that might be thrown and return the worker back to poolboy in a clean manner. It also allows
          # the programmer to retrieve the error and potentially fix it.
          try do
            Venezia.Worker.get_match_details(pid, url, team)
          catch
            e, r -> IO.inspect("poolboy transaction caught error: #{inspect(e)}, #{inspect(r)}")
            :ok
          end
        end,
        @timeout
      )
    end)
  end

  defp await_and_inspect(task), do: task |> Task.await(@timeout) |> IO.inspect()
end

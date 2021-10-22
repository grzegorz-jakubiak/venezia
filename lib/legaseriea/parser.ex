defmodule LegaSerieA.Parser do
  @moduledoc """
  This module is responsible for parsing the responses
  """

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://www.legaseriea.it")

  @spec round_urls :: list(binary()) | {:error, any}
  def round_urls do
    with {:ok, response} <- get("/en/serie-a/fixture-and-results"),
         {:ok, document} <- Floki.parse_document(response.body),
         round_nodes <- Floki.find(document, "#menu-giornate li:not(.nomegirone) a") do
      round_nodes |> Floki.attribute("href")
    else
      error -> error
    end
  end

  def match_details(match) do
    with details <- Floki.find(match, ".datipartita p"),
         date <- Floki.find(details, "span") |> Floki.text() |> String.trim(),
         {_, _, children} <- List.first(details),
         <<"Stadium: ", stadium::binary>> <-
           Enum.find(children, &contains_substring?(&1, "stadium"))
           |> String.trim(),
         teams <- Floki.find(match, ".nomesquadra") |> Enum.map(&Floki.text/1),
         score <-
           Floki.find(match, "[class*=risultat] span")
           |> Enum.map(fn elem ->
             case elem |> Floki.text() |> Integer.parse() do
               {num, _} -> num
               :error -> nil
             end
           end) do
      %{date: date, stadium: stadium, teams: teams, score: score}
    end
  end

  @spec find_match_by_team(binary, binary) :: list
  def find_match_by_team(url, team_name) do
    with {:ok, response} <- get(url),
         {:ok, document} = Floki.parse_document(response.body),
         nodes <- Floki.find(document, ".box-partita") do
      Enum.filter(nodes, &contains_substring?(&1, team_name))
    end
  end

  defp contains_substring?({_tag, _attributes, []}, _substring), do: false

  defp contains_substring?({_tag, _attributes, [head | _]}, substring) when is_binary(head) do
    contains_substring?(head, substring)
  end

  defp contains_substring?({_tag, _attributes, [_ | tail]}, substring),
    do: Enum.any?(tail, &contains_substring?(&1, substring))

  defp contains_substring?(text, substring) do
    text
    |> String.downcase()
    |> String.contains?(String.downcase(substring))
  end
end

defmodule LegaSerieA.Parser do
  @moduledoc """
  This module is responsible for parsing the responses
  """

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://www.legaseriea.it")

  @spec find_match_box_by_team(binary, binary) :: list
  def find_match_box_by_team(url, team_name) do
    with {:ok, response} <- get(url),
         {:ok, document} = Floki.parse_document(response.body),
         nodes <- Floki.find(document, ".box-partita") do
      Enum.filter(nodes, &contains_text?(&1, team_name))
    end
  end

  defp contains_text?({_tag, _attributes, children}, text) do
    case children do
      [] ->
        false

      [text_element | []] when is_binary(text_element) ->
        contains_text?(text_element, text)

      [_ | tail] ->
        Enum.any?(tail, &contains_text?(&1, text))
    end
  end

  defp contains_text?(text_element, text) when is_binary(text_element) do
    text_element
    |> String.downcase()
    |> String.contains?(String.downcase(text))
  end
end

defmodule LegaSerieA.ParserTest do
  use ExUnit.Case
  import Tesla.Mock

  setup_all do
    {:ok, html} = Path.join([__DIR__, "../parser_fixture.html"]) |> Path.absname() |> File.read()
    {:ok, parsed_html} = Floki.parse_document(html)
    [html: html, parsed_html: parsed_html]
  end

  setup context do
    %{url: url, html: html} = context

    mock(fn
      %{method: :get, url: ^url} ->
        %Tesla.Env{status: 200, body: html}
    end)

    :ok
  end

  describe "find_match_box_by_team" do
    @describetag url: "https://example.com"

    test "finds the box", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html
      assert t == LegaSerieA.Parser.find_match_box_by_team(url, "venezia")
    end

    test "is case insensitive", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html
      assert t == LegaSerieA.Parser.find_match_box_by_team(url, "VENEZIA")
    end

    test "returns empty list when it's not there", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html
      refute t == LegaSerieA.Parser.find_match_box_by_team(url, "test")
      assert [] == LegaSerieA.Parser.find_match_box_by_team(url, "test")
    end
  end
end

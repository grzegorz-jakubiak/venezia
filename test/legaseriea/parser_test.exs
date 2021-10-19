defmodule LegaSerieA.ParserTest do
  use ExUnit.Case
  import Tesla.Mock

  setup %{url: url, filename: filename} do
    {:ok, html} = Path.join([__DIR__, "../fixtures", filename]) |> Path.absname() |> File.read()
    {:ok, parsed_html} = Floki.parse_document(html)

    mock(fn
      %{method: :get, url: ^url} ->
        %Tesla.Env{status: 200, body: html}
    end)

    {:ok, parsed_html: parsed_html}
  end

  describe "find_match_box_by_team" do
    @describetag url: "https://example.com"
    @describetag filename: "matches_fixture.html"

    test "finds the box", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      assert t == LegaSerieA.Parser.find_match_box_by_team(url, "venezia")
    end

    test "is case insensitive", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      assert t == LegaSerieA.Parser.find_match_box_by_team(url, "VENEZIA")
    end

    test "returns empty list when it's not there", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      refute t == LegaSerieA.Parser.find_match_box_by_team(url, "test")
      assert [] == LegaSerieA.Parser.find_match_box_by_team(url, "test")
    end
  end
end

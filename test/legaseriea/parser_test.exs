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

  describe "match_details" do
    @describetag filename: "matches_fixture.html"
    @describetag url: "https://example.com"

    test "returns match details struct", %{parsed_html: parsed_html} do
      [box | _] = parsed_html |> Floki.find(".box-partita")

      assert %{
               date: "16/10/2021 15:00",
               stadium: "ALBERTO PICCO (La Spezia)",
               teams: ["Spezia", "Salernitana"],
               score: [2, 1]
             } == LegaSerieA.Parser.match_details(box)
    end
  end

  describe "find_match_by_team" do
    @describetag url: "https://example.com"
    @describetag filename: "matches_fixture.html"

    test "finds the box", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      assert t == LegaSerieA.Parser.find_match_by_team(url, "venezia")
    end

    test "is case insensitive", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      assert t == LegaSerieA.Parser.find_match_by_team(url, "VENEZIA")
    end

    test "returns empty list when it's not there", %{url: url, parsed_html: parsed_html} do
      [_ | t] = parsed_html |> Floki.find(".box-partita")
      refute t == LegaSerieA.Parser.find_match_by_team(url, "test")
      assert [] == LegaSerieA.Parser.find_match_by_team(url, "test")
    end
  end

  describe "round_urls" do
    @describetag url: "https://www.legaseriea.it/en/serie-a/fixture-and-results"
    @describetag filename: "rounds_fixture.html"

    test "return list of urls" do
      assert [
               "/en/serie-a/fixture-and-results/2021-22/UNICO/UNI/1",
               "/en/serie-a/fixture-and-results/2021-22/UNICO/UNI/2",
               "/en/serie-a/fixture-and-results/2021-22/UNICO/UNI/20"
             ] == LegaSerieA.Parser.round_urls()
    end
  end
end

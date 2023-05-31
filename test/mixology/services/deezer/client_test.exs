defmodule Mixology.Services.Deezer.ClientTest do
  use ExUnit.Case, async: true
  use ExVCR.Casette

  alias Mixology.Services.Deezer.Client

  test "get_favourite_albums" do
    {:ok, %{"data" => data}} = Client.get_favourite_albums("The Beatles")
    assert Enum.count(data) > 0
  end
end

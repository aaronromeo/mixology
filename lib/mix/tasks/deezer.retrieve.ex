defmodule Mix.Tasks.Deezer.Retrieve do
  use Mix.Task
  alias Mixology.Workers.FetchAlbums
  require Logger

  @shortdoc false

  @moduledoc """
  This is where we would put any long form documentation and doctests.
  """

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    # %{} |> Mixology.Workers.FetchAlbums.new() |> Oban.insert()
    FetchAlbums.perform(%{})
  end
end

defmodule Mix.Tasks.Deezer.Retrieve do
  use Mix.Task
  alias Mixology.Users
  require Logger

  @shortdoc false

  @moduledoc """
  This is where we would put any long form documentation and doctests.
  """

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    user = Users.get_deezer_user("7798694")

    with true <- !is_nil(user) and !is_nil(user.access_token),
         {:ok, _user} <- Mixology.Services.DeezerService.reset_users_associations(user),
         {:ok, _favs} <- Mixology.Services.DeezerService.retrieve_favourite_albums(user),
         {:ok, _user} <- Mixology.Services.DeezerService.retrieve_album_details(user) do
      Logger.info("Retrieved favourites")
    else
      error ->
        Logger.error("Error connecting #{inspect(error)}")
    end
  end
end

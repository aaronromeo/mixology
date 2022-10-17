defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller
  alias Mixology.Users
  alias Mixology.Services.DeezerService
  require Logger

  def index(conn, params) do
    with true <- !is_nil(params["user_id"]),
         user <- Users.get_deezer_user(params["user_id"]),
         true <- !is_nil(user) and !is_nil(user.access_token),
         {:ok, _user} <- DeezerService.reset_users_associations(user),
         {:ok, _favs} <- DeezerService.retrieve_favourite_albums(user) do
      Logger.info("Retrieved favourites")
      render(conn, "index.html")
    else
      error ->
        Logger.error("Error connecting #{inspect(error, pretty: true)}")

        conn
        |> redirect(external: DeezerService.connect_uri())
    end
  end
end

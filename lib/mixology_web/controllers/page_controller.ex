defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller
  alias Mixology.Albums
  alias Mixology.Users
  alias Mixology.Services.DeezerService
  require Logger

  def index(conn, params) do
    with true <- !is_nil(params["user_id"]),
         user <- Users.get_deezer_user(params["user_id"]),
         true <- !is_nil(user) and !is_nil(user.access_token),
         {:ok, albums} <- DeezerService.get_recommendations(user) do
      Albums.queue_fetch_albums(user.id)

      render(conn, "index.html", albums: albums)
    else
      error ->
        Logger.error("Error connecting #{inspect(error, pretty: true)}")

        conn
        |> redirect(external: DeezerService.connect_uri())
    end
  end
end

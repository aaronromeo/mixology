defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller
  # alias Mixology.Users.User
  alias Mixology.Users
  require Logger

  def index(conn, _params) do
    user = Users.get_deezer_user("7798694")

    if is_nil(user) || is_nil(user.access_token) do
      conn
      |> redirect(external: Mixology.Services.DeezerService.connect_uri())
    end

    # Mixology.Services.DeezerService.save_user(user.access_token)

    favourites = Mixology.Services.DeezerService.retrieve_favourite_albums(user.access_token)

    # TODO: Save `access_token` to a user

    Logger.info("Retrieved favourites")
    # Logger.info(favourites)
    IO.inspect(favourites)

    render(conn, "index.html")
  end
end

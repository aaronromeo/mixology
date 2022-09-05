defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller
  # alias Mixology.Users.User
  alias Mixology.Users
  require Logger

  def index(conn, _params) do
    user = Users.get_deezer_user("7798694")

    if is_nil(user) or is_nil(user.access_token) do
      conn
      |> redirect(external: Mixology.Services.DeezerService.connect_uri())
    end

    {_status, favourites} =
      user
      |> Mixology.Services.DeezerService.reset_users_associations()
      |> Mixology.Services.DeezerService.retrieve_favourite_albums()

    Logger.info("Retrieved favourites")

    # Logger.info(favourites)
    IO.inspect(favourites)

    render(conn, "index.html")
  end
end

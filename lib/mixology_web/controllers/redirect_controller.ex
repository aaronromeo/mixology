defmodule MixologyWeb.RedirectController do
  use MixologyWeb, :controller
  require Logger

  def index(conn, params) do
    favourites =
      params["code"]
      |> Mixology.Services.DeezerService.retrieve_access_token()
      |> Mixology.Services.DeezerService.retrieve_favourite_albums()

    # TODO: Save `access_token` to a user

    Logger.info("Retrieved favourites")
    # Logger.info(favourites)
    IO.inspect(favourites)

    render(conn, "index.html")
  end
end

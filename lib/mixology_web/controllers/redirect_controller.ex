defmodule MixologyWeb.RedirectController do
  use MixologyWeb, :controller
  require Logger

  def index(conn, params) do
    access_token =
      params["code"]
      |> Mixology.Services.DeezerService.retrieve_access_token()

    Mixology.Services.DeezerService.save_user(access_token)

    # favourites = Mixology.Services.DeezerService.retrieve_favourite_albums(access_token)

    # # TODO: Save `access_token` to a user

    # Logger.info("Retrieved favourites")
    # # Logger.info(favourites)
    # IO.inspect(favourites)

    # render(conn, "index.html")

    page_path = Routes.page_path(conn, :index)

    conn
    |> redirect(to: page_path)
    |> Plug.Conn.halt()
  end
end

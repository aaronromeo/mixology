defmodule MixologyWeb.RedirectController do
  use MixologyWeb, :controller

  def index(conn, params) do
    access_token_uri =
      params["code"]
      |> Mixology.Services.DeezerService.retrieve_access_token()

    render(conn, "index.html")
  end
end

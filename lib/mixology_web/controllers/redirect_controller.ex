defmodule MixologyWeb.RedirectController do
  use MixologyWeb, :controller
  require Logger

  def index(conn, params) do
    with {:ok, access_token} <-
           Mixology.Services.DeezerService.retrieve_access_token(params["code"]),
         {:ok, _user} <- Mixology.Services.DeezerService.save_user(access_token) do
      page_path = Routes.page_path(conn, :index)

      conn
      |> redirect(to: page_path)
      |> Plug.Conn.halt()
    else
      {:error, msg} ->
        {:error, msg}

      _error ->
        {:error, "Unable to retrieve access token"}
    end
  end
end

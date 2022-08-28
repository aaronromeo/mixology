defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(external: Mixology.Services.DeezerService.connect_uri())
    |> Plug.Conn.halt()
  end
end

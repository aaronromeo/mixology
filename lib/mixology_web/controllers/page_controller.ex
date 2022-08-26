defmodule MixologyWeb.PageController do
  use MixologyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

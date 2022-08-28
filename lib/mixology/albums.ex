defmodule Mixology.Albums do
  alias Mixology.Albums.Album
  alias Mixology.Repo
  import Ecto.Query

  def get_item(id) do
    Repo.get(Album, id)
  end

  def list_items() do
    query =
      Album
      |> order_by(:id)

    Repo.all(query)
  end

  def create_album(attrs) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end
end

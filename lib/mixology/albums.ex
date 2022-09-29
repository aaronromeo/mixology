defmodule Mixology.Albums do
  alias Mixology.Albums.Album
  alias Mixology.Repo
  import Ecto.Query

  def get_album(id) do
    Repo.get(Album, id)
  end

  def list_users_albums(user) do
    query =
      from a in Album,
        join: u in assoc(a, :users),
        preload: [users: u],
        where: u.id == ^user.id,
        order_by: a.id

    Repo.all(query)
  end

  def create_album(attrs) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_album(attrs) do
    album =
      if !is_nil(attrs[:deezer_uri]) do
        attr_uri = attrs[:deezer_uri]
        query = from a in Album, where: a.deezer_uri == ^attr_uri, preload: :users
        Repo.one(query)
      else
        %Album{}
      end

    if is_nil(album) || is_nil(album.id) do
      {:ok, album} =
        %Album{}
        |> Album.changeset(attrs)
        |> Repo.insert()

      album
    else
      album
    end
  end
end

defmodule Mixology.Albums do
  alias Mixology.Albums.Album
  alias Mixology.UsersAlbums.UserAlbum
  alias Mixology.Repo
  import Ecto.Query
  require Logger

  def get_album(id) do
    Repo.get(Album, id)
  end

  def list_stale_users_albums(user, stale_date) do
    query =
      from a in Album,
        join: u in assoc(a, :users),
        preload: [users: u],
        where: u.id == ^user.id and (a.detailed_at < ^stale_date or is_nil(a.detailed_at)),
        order_by: [desc: a.updated_at]

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
        Repo.one(query) || %Album{}
      else
        %Album{}
      end

    album_changeset = Album.changeset(album, attrs)

    cond do
      album_changeset.valid? and is_nil(album.id) ->
        Repo.insert(album_changeset)

      album_changeset.valid? and !is_nil(album.id) ->
        Repo.update(album_changeset)

      true ->
        Logger.error("Error saving changeset #{inspect(album_changeset)}")
        {:error, album}
    end
  end

  def delete_album(id) do
    ua_query = from ua in UserAlbum, where: ua.album_id == ^id
    Repo.delete_all(ua_query)

    a_query = from a in Album, where: a.id == ^id
    Repo.delete_all(a_query)
  end
end

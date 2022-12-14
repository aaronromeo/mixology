defmodule Mixology.Users do
  alias Mixology.Albums.Album
  alias Mixology.Users.User
  alias Mixology.UsersAlbums.UserAlbum

  alias Mixology.Repo
  import Ecto.Query
  require Logger

  # Repo.one(from u in User, where: not is_nil(u.id), limit: 1, preload: :albums)

  def get_deezer_user(deezer_id) do
    query = from u in User, where: u.deezer_id == ^deezer_id, preload: :albums

    Repo.one(query)
  end

  def find_or_create_user(attrs) do
    instance =
      if !is_nil(attrs[:deezer_id]) do
        uniq_id = attrs[:deezer_id]
        query = from a in User, where: a.deezer_id == ^uniq_id
        Repo.one(query)
      else
        %User{}
      end

    if is_nil(instance) || is_nil(instance.id) do
      {:ok, instance} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      instance
    else
      instance
    end
  end

  def disassociation_albums_to_user(user) do
    Repo.delete_all(from ua in UserAlbum, where: ua.user_id == ^user.id)
  end

  def association_album_to_user(user, album) do
    %UserAlbum{}
    |> UserAlbum.changeset(%{album_id: album.id, user_id: user.id})
    |> Repo.insert()
  rescue
    Ecto.ConstraintError ->
      Logger.warn(["Duplicate Favourite detected ", album.id, user.id])

      {:ok,
       Repo.one(
         from ua in UserAlbum,
           where: ua.album_id == ^album.id and ua.user_id == ^user.id
       )}
  end

  def update_token(user, access_token \\ nil) do
    Repo.update(user |> Mixology.Users.User.changeset(%{access_token: access_token}))
  end

  def get_album_count(user) do
    Repo.one(from ua in UserAlbum, where: ua.user_id == ^user.id, select: count())
  end

  def get_random_albums(user) do
    query =
      from a in Album,
        join: ua in UserAlbum,
        on: a.id == ua.album_id,
        where: ua.user_id == ^user.id,
        order_by: fragment("RANDOM()"),
        limit: 15

    Repo.all(query)
  end
end

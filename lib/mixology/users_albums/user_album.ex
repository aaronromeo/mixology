defmodule Mixology.UsersAlbums.UserAlbum do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mixology.Albums.Album
  alias Mixology.Users.User

  schema "users_albums" do
    belongs_to :user, User
    belongs_to :album, Album
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:album_id, :user_id])
    |> validate_required([:album_id, :user_id])
    |> unique_constraint([:album_id, :user_id])

    # |> cast_assoc(
    #   :user,
    #   required: true
    # )
    # |> cast_assoc(
    #   :album,
    #   required: true
    # )
  end
end

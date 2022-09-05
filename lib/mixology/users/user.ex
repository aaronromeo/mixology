defmodule Mixology.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mixology.Albums.Album
  alias Mixology.UsersAlbums.UserAlbum

  schema "users" do
    field :access_token, :string
    field :deezer_id, :string
    field :name, :string

    many_to_many :albums, Album, join_through: UserAlbum, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:deezer_id, :name, :access_token])
    |> validate_required([:deezer_id, :name])
    |> unique_constraint(:deezer_id)
  end
end

defmodule Mixology.Albums.Album do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mixology.Albums.Album
  alias Mixology.UsersAlbums.UserAlbum

  schema "albums" do
    field :artist, :string
    field :deezer_uri, :string
    field :title, :string
    field :explicit_lyrics, :boolean
    field :cover_art, :string
    field :track_count, :integer
    field :duration, :integer
    field :genres, {:array, :integer}

    many_to_many :users, Mixology.Users.User, join_through: UserAlbum, on_replace: :delete

    timestamps()
  end

  @required_fields ~w(title artist deezer_uri explicit_lyrics track_count duration genres)a
  @changeset_fields List.flatten(@required_fields, ~w(cover_art)a)

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, @changeset_fields)
    |> validate_required(@required_fields)
  end

  @doc false
  def changeset_update_users(%Album{} = album, users) do
    album
    |> cast(%{}, @changeset_fields)
    |> validate_required(@required_fields)
    |> put_assoc(:users, users)
  end
end

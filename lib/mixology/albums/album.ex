defmodule Mixology.Albums.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :artist, :string
    field :deezer_uri, :string
    field :title, :string
    field :explicit_lyrics, :boolean
    field :cover_art, :string
    field :track_count, :integer
    field :duration, :integer
    field :genres, {:array, :integer}

    many_to_many :users, Mixology.Users.User, join_through: "users_albums"

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [
      :title,
      :artist,
      :deezer_uri,
      :explicit_lyrics,
      :cover_art,
      :track_count,
      :duration,
      :genres
    ])
    |> validate_required([
      :title,
      :artist,
      :deezer_uri,
      :explicit_lyrics,
      :track_count,
      :duration,
      :genres
    ])
  end
end

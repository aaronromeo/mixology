defmodule Mixology.Albums.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :artist, :string
    field :deezer_uri, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:title, :artist, :deezer_uri])
    |> validate_required([:title, :artist, :deezer_uri])
  end
end

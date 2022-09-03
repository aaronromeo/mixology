defmodule Mixology.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :access_token, :string
    field :deezer_id, :string
    field :name, :string

    many_to_many :albums, Mixology.Albums.Album, join_through: "users_albums"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:deezer_id, :name, :access_token])
    |> validate_required([:deezer_id, :name, :access_token])
    |> unique_constraint(:deezer_id)
  end
end

defmodule Mixology.Genres.Genre do
  use Ecto.Schema
  import Ecto.Changeset

  schema "genres" do
    field :deezer_id, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name, :deezer_id])
    |> validate_required([:name, :deezer_id])
  end
end

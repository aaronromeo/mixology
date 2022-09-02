defmodule Mixology.Genres do
  alias Mixology.Genres.Genre
  alias Mixology.Repo
  import Ecto.Query

  def find_or_create_genre(attrs) do
    genre =
      if !is_nil(attrs[:deezer_id]) do
        attr_id = attrs[:deezer_id]
        query = from g in Genre, where: g.deezer_id == ^attr_id
        Repo.one(query)
      else
        %Genre{}
      end

    if is_nil(genre) || is_nil(genre.id) do
      {:ok, genre} =
        %Genre{}
        |> Genre.changeset(attrs)
        |> Repo.insert()

      genre
    else
      genre
    end
  end
end

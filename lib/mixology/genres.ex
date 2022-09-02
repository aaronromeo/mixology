defmodule Mixology.Genres do
  alias Mixology.Genres.Genre
  alias Mixology.Repo
  # import Ecto.Query

  def find_or_create(genre_params) do
    {:ok, genre} = %Genre{}
      |> Genre.changeset(genre_params)
      |> Repo.one()

    if is_nil(genre.id) do
      %Genre{}
      |> Genre.changeset(genre_params)
      |> Repo.insert()
    else
      genre
    end
  end
end

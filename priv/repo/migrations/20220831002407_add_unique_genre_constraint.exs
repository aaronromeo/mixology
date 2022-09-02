defmodule Mixology.Repo.Migrations.AddUniqueGenreConstraint do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :genres,
        ~w(deezer_id)a,
        name: :index_for_genre_duplicate_entries
      )
    )
  end
end

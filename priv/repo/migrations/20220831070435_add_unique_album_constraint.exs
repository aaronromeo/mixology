defmodule Mixology.Repo.Migrations.AddUniqueAlbumConstraint do
  use Ecto.Migration

  def change do
    create(
      unique_index(
        :albums,
        ~w(deezer_uri)a,
        name: :index_for_album_duplicate_entries
      )
    )
  end
end

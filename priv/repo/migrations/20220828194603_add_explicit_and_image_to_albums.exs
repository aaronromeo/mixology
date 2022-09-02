defmodule Mixology.Repo.Migrations.AddExplicitAndImageToAlbums do
  use Ecto.Migration

  def change do
    alter table("albums") do
      add :explicit_lyrics, :boolean
      add :cover_art, :string
      add :track_count, :integer
      add :duration, :integer
      add :genres, {:array, :integer}
    end
  end
end

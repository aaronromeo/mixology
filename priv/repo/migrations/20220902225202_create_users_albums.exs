defmodule Mixology.Repo.Migrations.CreateUsersAlbums do
  use Ecto.Migration

  def change do
    create table(:users_albums) do
      add :user_id, references(:users)
      add :album_id, references(:albums)
    end

    create unique_index(:users_albums, [:user_id, :album_id])
  end
end

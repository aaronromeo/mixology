defmodule Mixology.Repo.Migrations.AddDeezerId do
  use Ecto.Migration
  alias Mixology.Albums.Album
  alias Mixology.UsersAlbums.UserAlbum
  alias Mixology.Repo

  def change do
    Repo.delete_all(UserAlbum)
    Repo.delete_all(Album)

    alter table("albums") do
      add :deezer_id, :integer, null: false
      add :detailed_at, :utc_datetime
    end
  end
end

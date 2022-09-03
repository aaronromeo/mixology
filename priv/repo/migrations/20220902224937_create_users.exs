defmodule Mixology.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :deezer_id, :string
      add :name, :string
      add :access_token, :string

      timestamps()
    end

    create unique_index(:users, [:deezer_id])
  end
end

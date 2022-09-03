defmodule Mixology.Users do
  alias Mixology.Users.User
  alias Mixology.Repo
  import Ecto.Query

  def get_deezer_user(deezer_id) do
    query = from u in User, where: u.deezer_id == ^deezer_id

    Repo.one(query)
  end

  def find_or_create_user(attrs) do
    instance =
      if !is_nil(attrs[:deezer_id]) do
        uniq_id = attrs[:deezer_id]
        query = from a in User, where: a.deezer_id == ^uniq_id
        Repo.one(query)
      else
        %User{}
      end

    if is_nil(instance) || is_nil(instance.id) do
      {:ok, instance} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      instance
    else
      instance
    end
  end
end

defmodule Mixology.Workers.FetchAlbums do
  use Oban.Worker, queue: :default, unique: [period: 300]
  alias Mixology.Users.User
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id} = _args}) do
    users = [Mixology.Repo.get(User, user_id)]

    helper(users)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: nil}) do
    users = Mixology.Repo.all(User)

    helper(users)
  end

  defp helper([%User{}] = users) do
    errors = Enum.map(users, fn user ->
      with true <- !is_nil(user) and !is_nil(user.access_token),
           {:ok, _user} <- Mixology.Services.DeezerService.reset_users_associations(user),
           {:ok, _favs} <- Mixology.Services.DeezerService.retrieve_favourite_albums(user),
           {:ok, _user} <- Mixology.Services.DeezerService.retrieve_album_details(user) do
        Logger.info("Retrieved favourites")

        :ok
      else
        error ->
          Logger.error("Error connecting #{inspect(error)}")

          {:error, error}
      end
    end) |>
    Enum.filter(fn x -> x != :ok end)

    if is_nil(errors) || length(errors) == 0 do
      :ok
    else
      {:error, errors}
    end
  end
end

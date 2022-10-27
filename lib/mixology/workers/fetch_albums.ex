defmodule Mixology.Workers.FetchAlbums do
  use Oban.Worker, queue: :default, unique: [period: 300]
  alias Mixology.Users.User
  require Logger

  @impl Oban.Worker
  def perform(_args) do
    users = Mixology.Repo.all(User)

    Enum.map(users, fn user ->
      with true <- !is_nil(user) and !is_nil(user.access_token),
           {:ok, _user} <- Mixology.Services.DeezerService.reset_users_associations(user),
           {:ok, _favs} <- Mixology.Services.DeezerService.retrieve_favourite_albums(user),
           {:ok, _user} <- Mixology.Services.DeezerService.retrieve_album_details(user) do
        Logger.info("Retrieved favourites")
      else
        error ->
          Logger.error("Error connecting #{inspect(error)}")
      end
    end)

    :ok
  end
end

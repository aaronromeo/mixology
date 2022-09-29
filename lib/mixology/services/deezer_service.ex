defmodule Mixology.Services.DeezerService do
  require Logger
  # alias Mixology.Genres.Genre
  alias Mixology.Genres
  # alias Mixology.Albums.Album
  alias Mixology.Albums
  alias Mixology.Users

  def connect_uri do
    "https://connect.deezer.com/oauth/auth.php?app_id=#{app_id()}&redirect_uri=#{redirect_uri()}&perms=offline_access,basic_access,manage_library"
  end

  def retrieve_access_token(code) do
    access_token_uri =
      "https://connect.deezer.com/oauth/access_token.php?app_id=#{app_id()}&secret=#{app_secret()}&code=#{code}"

    case Deezer.Client.get(access_token_uri) do
      {:ok, response} ->
        access_token =
          response.body
          |> String.split("&")
          |> List.first()
          |> String.split("=")
          |> List.last()

        {:ok, access_token}

      {:error, response} ->
        Logger.error("Error in retrieve_access_token")
        Logger.error(Map.from_struct(response))
        {:error, %{status_code: response.status, body: response.body}}
    end
  end

  def reset_users_associations(user) do
    Users.disassociation_albums_to_user(user)

    {:ok, user}
  end

  def retrieve_favourite_albums(user)
      when not is_nil(user.access_token) and not is_nil(user.id) do
    retrieve_favourite_albums(user, nil)
  end

  def retrieve_favourite_albums(user, next)
      when not is_nil(user.access_token) and not is_nil(user.id) do
    {status, response} =
      if is_nil(next) do
        Deezer.Client.get(user_albums_fetch_uri(), %{access_token: user.access_token})
      else
        Deezer.Client.get(next)
      end

    if status == :ok && response_valid?(response) do
      body = Jason.decode!(response.body)

      Enum.each(body["data"], fn album_summary ->
        upsert_favourite_album(user, album_summary)
      end)

      if not is_nil(body["next"]) do
        retrieve_favourite_albums(user, body["next"])
      else
        {:ok, user}
      end
    else
      Logger.error("Error in retrieve_favourite_albums")
      Logger.error(Map.from_struct(response))
      {:error, %{status_code: response.status, body: response.body}}
    end
  end

  def retrieve_album_details(user)
      when not is_nil(user.access_token) and not is_nil(user.id) do

    retrieve_album_details_helper(user, Albums.list_users_albums(user))

    {:ok, user}
  end

  def save_user(access_token) do
    {status, response} = Deezer.Client.get(user_fetch_uri(), %{access_token: access_token})

    if status == :ok && response_valid?(response) do
      body = Jason.decode!(response.body)

      attrs = %{
        name: body["name"],
        deezer_id: Integer.to_string(body["id"]),
        access_token: access_token
      }

      user =
        Users.find_or_create_user(attrs)
        |> Users.update_token(access_token)

      {:ok, user}
    else
      Logger.error("Error in retrieve_album_details")
      Logger.error(Map.from_struct(response))
      {:error, %{status_code: response.status, body: response.body}}
    end
  end

  defp app_id(), do: System.get_env("DEEZER_APP_ID")
  defp redirect_uri(), do: System.get_env("DEEZER_REDIRECT_URI")
  defp app_secret(), do: System.get_env("DEEZER_APP_SECRET")

  defp albums_fetch_uri(album_id), do: "https://api.deezer.com/album/#{album_id}"
  defp user_albums_fetch_uri, do: "https://api.deezer.com/user/me/albums"
  defp user_fetch_uri, do: "https://api.deezer.com/user/me"

  defp upsert_favourite_album(user, album_summary, album_details \\ %{}) do
    artist = get_in(album_summary, ["artist", "name"])
    deezer_uri = get_in(album_summary, ["link"])
    title = get_in(album_summary, ["title"])

    genres =
      if is_nil(get_in(album_details, ["genres", "data"])) do
        Logger.warn("Unable to find Album data)")
        Logger.warn(album_summary)
        []
      else
        Enum.map(get_in(album_details, ["genres", "data"]), fn gj ->
          genre_params = %{
            name: get_in(gj, ["name"]),
            deezer_id: get_in(gj, ["id"])
          }

          Genres.find_or_create_genre(genre_params).id
        end)
      end

    album_params = %{
      artist: artist,
      deezer_uri: deezer_uri,
      title: title,
      explicit_lyrics: get_in(album_summary, ["explicit_lyrics"]),
      cover_art: get_in(album_summary, ["cover_big"]),
      track_count: get_in(album_summary, ["nb_tracks"]),
      duration: if(album_details == %{}, do: 0, else: get_in(album_details, ["duration"])),
      genres: genres
    }

    IO.inspect("album_params")
    IO.inspect(album_params)
    album = Albums.find_or_create_album(album_params)
    Users.association_album_to_user(user, album)

    album
  end

  defp retrieve_album_details_helper(user, [album | rest]) do
    # IO.inspect(album)
    case Deezer.Client.get(albums_fetch_uri(album.id), %{access_token: user.access_token}) do
      {:error, response} ->
        Logger.error("Error in retrieve_album_details")
        Logger.error(Map.from_struct(response))
        {:error, %{status_code: response.status, body: response.body}}
      {:ok, response} ->
        # Need to validate response here

        album_details = Jason.decode!(response.body)
        IO.inspect(album_details)
        upsert_favourite_album(user, Map.from_struct(album), album_details)
        retrieve_album_details_helper(user, rest)
    end
  end

  defp retrieve_album_details_helper(_user, []), do: {:ok, true}

  defp response_valid?(response) do
    # IO.inspect(response)
    body = Jason.decode!(response.body)

    cond do
      !Enum.member?(response.headers, {"content-type", "application/json; charset=utf-8"}) ->
        false

      not is_nil(body["error"]) ->
        false

      true ->
        true
    end
  end
end

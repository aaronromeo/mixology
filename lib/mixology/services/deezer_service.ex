defmodule Mixology.Services.DeezerService do
  require Logger
  # alias Mixology.Genres.Genre
  alias Mixology.Genres
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

  def get_recommendations(user) do
    if Users.get_album_count(user) > 0 do
      # TODO: User should be queued for a refresh
      {:ok, Users.get_random_albums(user)}
    else
      with {:ok, _user} <- reset_users_associations(user),
           {:ok, _favs} <- retrieve_favourite_albums(user) do
        {:ok, Users.get_random_albums(user)}
      else
        error ->
          Logger.error(["get_recommendations error", inspect(error, pretty: true)])
      end
    end
  end

  def reset_users_associations(_user = nil) do
    {:error, nil}
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
        if !get_in(album_summary, ["available"]) && !get_in(album_summary, ["alternative"]) do
          Logger.error("Album is not available #{inspect(album_summary, pretty: true)}")
        else
          upsert_favourite_album_summary(user, album_summary)
        end
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
    stale_date = NaiveDateTime.add(NaiveDateTime.utc_now(), -30, :day)
    retrieve_album_details_helper(user, Albums.list_stale_users_albums(user, stale_date))

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

      Users.find_or_create_user(attrs)
      |> Users.update_token(access_token)
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

  defp upsert_favourite_album_summary(user, album_summary) do
    artist = get_in(album_summary, ["artist", "name"])

    [deezer_uri, deezer_id] =
      if get_in(album_summary, ["available"]) do
        [
          get_in(album_summary, ["link"]),
          get_in(album_summary, ["id"])
        ]
      else
        [
          get_in(album_summary, ["alternative", "link"]),
          get_in(album_summary, ["alternative", "id"])
        ]
      end

    title = get_in(album_summary, ["title"])

    album_params = %{
      artist: artist,
      deezer_uri: deezer_uri,
      deezer_id: deezer_id,
      title: title,
      explicit_lyrics: get_in(album_summary, ["explicit_lyrics"]),
      cover_art: get_in(album_summary, ["cover_big"]),
      track_count: get_in(album_summary, ["nb_tracks"])
    }

    with {:ok, album} <- Albums.find_or_create_album(album_params),
         {:ok, _ua} <- Users.association_album_to_user(user, album) do
      {:ok, album}
    else
      {:error, data} ->
        Logger.error("Album summary is not valid - #{inspect(data)}")
        Logger.error("Album summary is not valid - album_summary - #{inspect(album_summary)}")
        {:error, data}
    end
  end

  defp upsert_favourite_album_details(album_summary, album_details) do
    genres =
      if is_nil(get_in(album_details, ["genres", "data"])) do
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

    album_params =
      Map.merge(album_summary, %{
        duration: if(album_details == %{}, do: 0, else: get_in(album_details, ["duration"])),
        genres: genres,
        detailed_at: NaiveDateTime.utc_now()
      })

    with {:ok, album} <- Albums.find_or_create_album(album_params) do
      {:ok, album}
    else
      {:error, data} ->
        Logger.error("Album summary is not valid - #{inspect(data)}")
        Logger.error("Album summary is not valid - album_summary - #{inspect(album_summary)}")
        Logger.error("Album details is not valid - album_details - #{inspect(album_details)}")
        {:error, data}
    end
  end

  defp retrieve_album_details_helper(user, [album | rest]) do
    # IO.inspect(album, label: "retrieve_album_details_helper album")

    with {:ok, response} <-
           Deezer.Client.get(albums_fetch_uri(album.deezer_id), %{access_token: user.access_token}),
         {:ok, album_details} <- Jason.decode(response.body) do
      # Need to validate response here
      Logger.debug("Retrieving album #{album.id}")

      cond do
        get_in(album_details, ["error", "type"]) |> is_nil ->
          upsert_favourite_album_details(Map.from_struct(album), album_details)

        get_in(album_details, ["error", "type"]) == "DataException" ->
          Logger.error("Deezer does not have the album details #{inspect(album)}")
          Albums.delete_album(album.id)

        true ->
          Logger.error(
            "Error retrieving album #{get_in(album_details, ["error", "type"])} #{inspect(album)}"
          )
      end

      retrieve_album_details_helper(user, rest)
    else
      {:error, msg} ->
        Logger.error("Error in retrieve_album_details")
        Logger.error(msg)

      # {:error, %{status_code: response.status, body: response.body}}
      _error ->
        Logger.error("Error in retrieve_album_details - General error")
        # {:error, %{status_code: response.status, body: response.body}}
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

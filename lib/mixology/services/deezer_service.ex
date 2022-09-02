defmodule Mixology.Services.DeezerService do
  require Logger
  # alias Mixology.Genres.Genre
  alias Mixology.Genres
  # alias Mixology.Albums.Album
  alias Mixology.Albums

  def connect_uri do
    "https://connect.deezer.com/oauth/auth.php?app_id=#{app_id()}&redirect_uri=#{redirect_uri()}&perms=offline_access,basic_access,manage_library"
  end

  def retrieve_access_token(code) do
    access_token_uri =
      "https://connect.deezer.com/oauth/access_token.php?app_id=#{app_id()}&secret=#{app_secret()}&code=#{code}"

    response = HTTPotion.get(access_token_uri)
    IO.inspect(response)

    if HTTPotion.Response.success?(response) do
      response.body
      |> String.split("&")
      |> List.first()
      |> String.split("=")
      |> List.last()
    else
      Logger.error("Error in retrieve_access_token")
      Logger.error(Map.from_struct(response))
      {:error, %{status_code: response.status_code, body: response.body}}
    end
  end

  def retrieve_favourite_albums(access_token) do
    retrieve_favourite_albums(access_token, nil)
  end

  def retrieve_favourite_albums(access_token, next) do
    response =
      if is_nil(next) do
        HTTPotion.get(user_albums_fetch_uri(), query: %{access_token: access_token})
      else
        HTTPotion.get(next)
      end

    # IO.inspect(response)

    if response_valid?(response) do
      body = Jason.decode!(response.body)

      serialize_favourite_album(access_token, body)

      if !is_nil(body["next"]) do
        {:ok, retrieve_favourite_albums(access_token, body["next"])}
      else
        {:ok, true}
      end
    else
      Logger.error("Error in retrieve_favourite_albums")
      Logger.error(Map.from_struct(response))
      {:error, %{status_code: response.status_code, body: response.body}}
    end
  end

  def retrieve_album_details(access_token, id) do
    response = HTTPotion.get(albums_fetch_uri(id), query: %{access_token: access_token})
    # IO.inspect(response)

    if response_valid?(response) do
      {:ok, Jason.decode!(response.body)}
    else
      Logger.error("Error in retrieve_album_details")
      Logger.error(Map.from_struct(response))
      {:error, %{status_code: response.status_code, body: response.body}}
    end
  end

  defp app_id(), do: System.get_env("DEEZER_APP_ID")
  defp redirect_uri(), do: System.get_env("DEEZER_REDIRECT_URI")
  defp app_secret(), do: System.get_env("DEEZER_APP_SECRET")

  defp albums_fetch_uri(album_id), do: "https://api.deezer.com/album/#{album_id}"
  defp user_albums_fetch_uri, do: "https://api.deezer.com/user/me/albums"

  defp serialize_favourite_album(access_token, favourite_list) do
    # IO.inspect(favourite_list)

    Enum.each(favourite_list["data"], fn album_summary ->
      # IO.inspect(album_summary)
      artist = get_in(album_summary, ["artist", "name"])
      deezer_uri = get_in(album_summary, ["link"])
      title = get_in(album_summary, ["title"])

      case retrieve_album_details(access_token, album_summary["id"]) do
        {:ok, album_details} ->
          genres =
            if is_nil(get_in(album_details, ["genres", "data"])) do
              Logger.warn("Unable to find Album data #{album_details})")
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
            track_count: get_in(album_details, ["nb_tracks"]),
            duration: get_in(album_details, ["duration"]),
            genres: genres
          }

          Albums.find_or_create_album(album_params)

        {:error, _ret} ->
          Logger.warn("Unable to find Album #{artist} #{title} (#{deezer_uri})")
          nil
      end
    end)
  end

  defp response_valid?(response) do
    IO.inspect(response)
    body = Jason.decode!(response.body)
    cond do
      !HTTPotion.Response.success?(response) -> false
      response.headers["content-type"] != "application/json; charset=utf-8" -> false
      !is_nil(body["error"]) -> false
      true -> true
    end
  end
end

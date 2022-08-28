defmodule Mixology.Services.DeezerService do
  require Logger

  def connect_uri do
    "https://connect.deezer.com/oauth/auth.php?app_id=#{app_id()}&redirect_uri=#{redirect_uri()}&perms=basic_access,manage_library"
  end

  def retrieve_access_token(code) do
    access_token_uri =
      "https://connect.deezer.com/oauth/access_token.php?app_id=#{app_id()}&secret=#{app_secret()}&code=#{code}"

    response = HTTPotion.get(access_token_uri)

    IO.inspect(response)

    if HTTPotion.Response.success?(response) do
      Logger.info(response.body)

      access_token =
        response.body
        |> String.split("&")
        |> List.first()
        |> String.split("=")
        |> List.last()

      Logger.info(access_token)
    else
      Logger.error("You done fuck up!")
    end
  end

  defp app_id(), do: System.get_env("DEEZER_APP_ID")
  defp redirect_uri(), do: System.get_env("DEEZER_REDIRECT_URI")
  defp app_secret(), do: System.get_env("DEEZER_APP_SECRET")
end

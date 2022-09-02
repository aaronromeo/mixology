defmodule Deezer.Client do
  def get(path, params \\ %{}) do
    case params do
      params when params == %{} ->
        Tesla.get(client(), path)

      %{} ->
        Tesla.get(client(), path, query: params)
    end
  end

  defp client do
    middleware = [
      Tesla.Middleware.EncodeJson
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end
end

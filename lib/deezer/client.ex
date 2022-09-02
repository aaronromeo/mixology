defmodule Deezer.Client do
  def get(path, params \\ %{}) do
    IO.inspect(path)
    IO.inspect(params)

    response =
      case params do
        params when params == %{} ->
          IO.inspect("In nil params case")
          HTTPotion.get(path)

        %{} ->
          IO.inspect("In general case")
          HTTPotion.get(path, query: params)
      end

    if HTTPotion.Response.success?(response), do: {:ok, response}, else: {:error, response}
  end
end

defmodule MixologyWeb.PageView do
  use MixologyWeb, :view

  @spec deezer_schema_uri(String.t()) :: String.t()
  def deezer_schema_uri(uri), do: to_string(%{URI.parse(uri) | scheme: "deezer", port: nil})
end

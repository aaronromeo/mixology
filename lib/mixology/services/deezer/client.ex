defmodule Mixology.Services.Deezer.Client do
  @behaviour Mixology.Services.Abstract

  def get_recommendations(_user), do: {:ok, []}

  def get_favourite_albums(_user), do: {:ok, []}
end

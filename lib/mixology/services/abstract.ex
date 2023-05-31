defmodule Mixology.Services.Abstract do
  @callback get_recommendations(user :: term) :: {:ok, albums :: term} | {:error, reason :: term}
end

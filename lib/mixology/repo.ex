defmodule Mixology.Repo do
  use Ecto.Repo,
    otp_app: :mixology,
    adapter: Ecto.Adapters.Postgres
end

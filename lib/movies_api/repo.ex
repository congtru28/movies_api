defmodule MoviesApi.Repo do
  use Ecto.Repo,
    otp_app: :movies_api,
    adapter: Ecto.Adapters.Postgres
end

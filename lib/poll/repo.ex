defmodule Poll.Repo do
  use Ecto.Repo,
    otp_app: :poll,
    adapter: Ecto.Adapters.Postgres
end

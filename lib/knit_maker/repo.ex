defmodule KnitMaker.Repo do
  use Ecto.Repo,
    otp_app: :knit_maker,
    adapter: Ecto.Adapters.SQLite3
end

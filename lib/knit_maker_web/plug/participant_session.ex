defmodule KnitMakerWeb.Plug.ParticipantSession do
  @behaviour Plug

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_session(conn, "participant_id") do
      nil ->
        id = :crypto.strong_rand_bytes(10) |> Base.url_encode64(padding: false)
        put_session(conn, "participant_id", id)

      _id ->
        conn
    end
  end
end

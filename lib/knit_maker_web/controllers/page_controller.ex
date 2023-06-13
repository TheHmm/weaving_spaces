defmodule KnitMakerWeb.PageController do
  use KnitMakerWeb, :controller

  def home(conn, _params) do
    event = KnitMaker.Events.most_recent_event()

    if event do
      redirect(conn, to: "/" <> event.slug)
    else
      json(conn, %{ok: true})
    end
  end
end

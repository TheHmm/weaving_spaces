defmodule KnitMakerWeb.ImageController do
  use KnitMakerWeb, :controller

  alias KnitMaker.Events

  def render(conn, params) do
    event = Events.get_event!(params["id"])

    {:ok, image_data} =
      event
      |> KnitMaker.Visualizer.render(params["participant_id"])
      |> Pat.to_pixels(%{"1" => event.knitting_fg, "0" => event.knitting_bg})
      |> Pixels.encode_png()

    conn
    |> put_resp_content_type("image/png")
    |> put_resp_header("content-disposition", "inline; filename=knit.png")
    |> send_resp(200, image_data)
  end
end

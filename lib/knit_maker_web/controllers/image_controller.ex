defmodule KnitMakerWeb.ImageController do
  use KnitMakerWeb, :controller

  alias KnitMaker.Events

  def render(conn, params) do
    event = Events.get_event!(params["id"])

    {fg, bg} = colors(event, params)

    {:ok, image_data} =
      event
      |> KnitMaker.Visualizer.render(params["participant_id"])
      |> Pat.to_pixels(%{"1" => fg, "0" => bg})
      |> Pixels.encode_png()

    conn
    |> put_resp_content_type("image/png")
    |> put_resp_header("content-disposition", "inline; filename=knit.png")
    |> send_resp(200, image_data)
  end

  defp colors(_event, %{"bw" => "1"}) do
    {"#ffffff", "#000000"}
  end

  defp colors(event, _params) do
    {event.knitting_fg, event.knitting_bg}
  end
end

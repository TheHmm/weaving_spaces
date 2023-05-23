defmodule KnitMakerWeb.ImageController do
  use KnitMakerWeb, :controller

  def render(conn, params) do
    {:ok, knitting} = KnitMaker.Knitting.get_knitting_pat(params["id"])

    {:ok, data} =
      Pat.to_pixels(knitting, %{"1" => "#be0044", "0" => "#000278"})
      |> Pixels.encode_png()

    conn
    |> put_resp_content_type("image/png")
    |> put_resp_header("content-disposition", "attachment; filename=knit.png")
    |> send_resp(200, data)
  end
end

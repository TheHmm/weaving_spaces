defmodule KnitMakerWeb.ExportController do
  use KnitMakerWeb, :controller

  alias KnitMaker.Events

  def image(conn, params) do
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

  alias Elixlsx.Workbook
  alias Elixlsx.Sheet
  alias KnitMaker.Participants

  def excel(conn, params) do
    event = Events.get_event!(params["id"])
    filename = "event-export-#{event.id}.xlsx"

    question_lookup = event.questions |> Enum.map(&{&1.id, &1}) |> Map.new()

    sheet =
      Sheet.with_name(event.name)
      |> Sheet.set_cell("A1", "Participant", bold: true)
      |> Sheet.set_cell("B1", "Date", bold: true)
      |> Sheet.set_cell("C1", "Question ID", bold: true)
      |> Sheet.set_cell("D1", "Question", bold: true)
      |> Sheet.set_cell("E1", "Answer", bold: true)
      |> Sheet.set_cell("F1", "Value", bold: true)
      |> Sheet.set_col_width("A", 25)
      |> Sheet.set_col_width("B", 25)
      |> Sheet.set_col_width("C", 10)
      |> Sheet.set_col_width("D", 30)
      |> Sheet.set_col_width("E", 20)
      |> Sheet.set_col_width("F", 20)

    sheet =
      Participants.list_responses_by_event(event.id)
      |> Enum.with_index()
      |> Enum.reduce(sheet, fn {response, index}, sheet ->
        i = index + 2

        question =
          case question_lookup[response.question_id] do
            nil -> ""
            q -> q.title
          end

        sheet
        |> Sheet.set_cell("A#{i}", response.participant_id)
        |> Sheet.set_cell("B#{i}", response.inserted_at |> to_string())
        |> Sheet.set_cell("C#{i}", to_string(response.question_id))
        |> Sheet.set_cell("D#{i}", question)
        |> Sheet.set_cell("E#{i}", response.text || "")
        |> Sheet.set_cell("F#{i}", response.value || "")
      end)

    {:ok, {_, data}} =
      Workbook.append_sheet(%Workbook{}, sheet)
      |> Elixlsx.write_to_memory(filename)

    conn
    |> put_resp_content_type("application/vnd.ms-excel")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=#{filename}"
    )
    |> send_resp(200, data)
  end
end

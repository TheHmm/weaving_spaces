defmodule KnitMaker.Visualizer do
  import Pat

  alias KnitMaker.Participants

  def render(event_id) do
    Participants.grouped_responses_by_event(event_id)
    |> IO.inspect(label: "g")

    t = :erlang.system_time(:second) |> rem(10000)

    new_text("xxhello world\n#{t}", font: :knit, stride: 1)
    |> pad(1, "1")
    |> pad(1, "0")
    |> pad(1, "1")
    |> pad(1, "0")
  end
end

defmodule KnitMaker.Visualizer do
  import Pat

  def render() do
    t = :erlang.system_time(:second) |> rem(10000)

    new_text("xxhello world\n#{t}", font: :knit, stride: 1)
    |> pad(1, "1")
    |> pad(1, "0")
    |> pad(1, "1")
    |> pad(1, "0")
  end
end

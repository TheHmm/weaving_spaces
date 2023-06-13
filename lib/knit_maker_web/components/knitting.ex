defmodule KnitMakerWeb.Components.Knitting do
  use Phoenix.LiveComponent

  attr(:event, KnitMaker.Events.Event, required: true)
  attr(:pat, Pat, required: true)

  def render(assigns) do
    ~H"""
    <div>
    <style>
    .grid > span.c0 { background: <%= @event.knitting_bg || "#ffcc00" %> }
    .grid > span.c1 { background: <%= @event.knitting_fg || "#111111" %> }
    </style>
    <div
      class="grid"
      style={"grid-template-columns: " <> to_string(1..@pat.w |> Enum.map(fn _ -> " 1fr" end))}
    >
      <%= for row <- Pat.rows(@pat), col <- String.split(row, "", trim: true) do %>
        <span class={"c" <> col}></span>
      <% end %>
    </div>
    </div>
    """
  end
end

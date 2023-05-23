defmodule KnitMaker.Knitting do
  use GenServer
  require Logger

  alias KnitMaker.Visualizer

  def start_link(event_id) do
    GenServer.start_link(__MODULE__, event_id, name: via_tuple(event_id))
  end

  def get_knitting(event_id) do
    {:ok, pid} = KnitMaker.KnittingSupervisor.ensure_started(event_id)
    GenServer.call(pid, :get_knitting)
  end

  def via_tuple(event_id),
    do: {:via, Registry, {KnitMaker.KnittingRegistry, event_id}}

  def init(event_id) do
    Logger.warn("Knitting visualizer started: #{event_id}")
    :timer.send_interval(1000, :render)

    {:ok, render(%{event_id: event_id})}
  end

  def handle_call(:get_knitting, _from, state) do
    {:reply, {:ok, state.rendered}, state}
  end

  def handle_info(:render, state) do
    {:noreply, render(state)}
  end

  defmodule LiveRender do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div
        class="grid"
        style={"grid-template-columns: " <> to_string(1..@pat.w |> Enum.map(fn _ -> " 1fr" end))}
      >
        <%= for row <- Pat.rows(@pat), col <- String.split(row, "", trim: true) do %>
          <span class={"c" <> col}></span>
        <% end %>
      </div>
      """
    end
  end

  defp render(state) do
    pat = Visualizer.render(state.event_id)
    rendered = LiveRender.render(%{pat: pat})
    Map.put(state, :rendered, rendered)
  end
end

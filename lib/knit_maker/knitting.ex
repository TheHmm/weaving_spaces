defmodule KnitMaker.Knitting do
  use GenServer
  require Logger

  alias KnitMaker.Events
  alias KnitMaker.Visualizer

  def start_link(event_id) do
    GenServer.start_link(__MODULE__, event_id, name: via_tuple(event_id))
  end

  def get_knitting(event_id) do
    {:ok, pid} = KnitMaker.KnittingSupervisor.ensure_started(event_id)
    GenServer.call(pid, :get_knitting)
  end

  def get_knitting_pat(event_id) do
    {:ok, pid} = KnitMaker.KnittingSupervisor.ensure_started(event_id)
    GenServer.call(pid, :get_knitting_pat)
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

  def handle_call(:get_knitting_pat, _from, state) do
    {:reply, {:ok, state.pat}, state}
  end

  def handle_info(:render, state) do
    if people_connected?(state) do
      {:noreply, render(state)}
    else
      Logger.warn("Stopping knitting visualizer, nobody connected")

      {:stop, :normal, state}
    end
  end

  defp people_connected?(state) do
    KnitMakerWeb.Presence.list("event-#{state.event_id}") |> Enum.count() > 0
  end

  defp render(state) do
    event = Events.get_event!(state.event_id)
    pat = Visualizer.render(event, nil)

    rendered =
      KnitMakerWeb.Components.Knitting.render(%{
        pat: pat,
        event: event
      })

    state
    |> Map.put(:rendered, rendered)
    |> Map.put(:pat, pat)
  end
end

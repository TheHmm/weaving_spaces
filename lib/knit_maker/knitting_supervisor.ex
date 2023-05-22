defmodule KnitMaker.KnittingSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def ensure_started(event_id) do
    # ensure node started
    case Registry.lookup(KnitMaker.KnittingRegistry, event_id) do
      [{pid, nil}] ->
        {:ok, pid}

      [] ->
        child_spec = {KnitMaker.Knitting, event_id}
        DynamicSupervisor.start_child(__MODULE__, child_spec)
    end
  end

  @impl true
  def init(_arg) do
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

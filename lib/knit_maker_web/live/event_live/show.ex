defmodule KnitMakerWeb.EventLive.Show do
  use KnitMakerWeb, :live_view

  alias KnitMaker.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:event, Events.get_event!(id))
      |> assign(:questions, Events.list_questions(id))

    socket =
      case params["question_id"] do
        nil -> socket
        id -> socket |> assign(:question, Events.get_question!(id))
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:edit), do: "Edit Event"
  defp page_title(:add_question), do: "Add new Question"
  defp page_title(:edit_question), do: "Edit Question"
end

defmodule KnitMakerWeb.EventLive.Show do
  use KnitMakerWeb, :live_view

  alias KnitMaker.Events
  alias KnitMaker.Participants

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
      |> assign(:event_stats, Participants.get_event_stats(id))
      |> assign(:questions, Events.list_questions(id))

    socket =
      case params["question_id"] do
        nil -> socket
        id -> socket |> assign(:question, Events.get_question!(id))
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:questions), do: "Show Event questions"
  defp page_title(:edit), do: "Edit Event"
  defp page_title(:add_question), do: "Add new Question"
  defp page_title(:edit_question), do: "Edit Question"
  defp page_title(:config_question), do: "Configure Question"
  defp page_title(:visualize_question), do: "Configure Question visualize"

  @impl true
  def handle_event("reposition", %{"old" => idx, "new" => idx}, socket) do
    {:noreply, socket}
  end

  def handle_event("reposition", %{"new" => insert_idx, "id" => "row-" <> id_str}, socket) do
    {id, _} = Integer.parse(id_str, 10)
    question = Enum.find(socket.assigns.questions, &(&1.id == id))

    {:ok, new_questions} =
      KnitMaker.Repo.transaction(fn ->
        socket.assigns.questions
        |> Enum.filter(&(&1.id != id))
        |> List.insert_at(insert_idx, question)
        |> Enum.with_index()
        |> Enum.map(fn {question, rank} ->
          {:ok, q} = Events.update_question(question, %{rank: rank})
          q
        end)
      end)

    {:noreply,
     socket |> assign(:questions, new_questions) |> put_flash(:info, "Question ordering updated")}
  end
end

defmodule KnitMakerWeb.MainLive do
  use KnitMakerWeb, :live_view

  alias KnitMaker.Events

  @impl true
  def mount(%{"question_id" => question_id} = params, session, socket) do
    IO.inspect(session, label: "session")

    socket = load_all(socket, params)

    %{questions: questions} = socket.assigns
    idx = Enum.find_index(questions, &(to_string(&1.id) == question_id))

    socket =
      socket
      |> assign(:question, Enum.at(questions, idx))
      |> assign(:prev_question, (idx > 0 && Enum.at(questions, idx - 1)) || nil)
      |> assign(:next_question, Enum.at(questions, idx + 1))

    {:ok, socket}
  end

  def mount(params, _session, socket) do
    {:ok, load_all(socket, params)}
  end

  @impl true
  def handle_event("start", %{}, socket) do
    id = List.first(socket.assigns.questions).id
    {:noreply, redirect(socket, to: ~p"/#{socket.assigns.event.slug}/q/#{id}")}
  end

  def handle_event("next", %{}, socket) do
    id = socket.assigns.next_question.id
    {:noreply, redirect(socket, to: ~p"/#{socket.assigns.event.slug}/q/#{id}")}
  end

  defp load_all(socket, %{"slug" => slug}) do
    event = Events.get_event_by_slug!(slug)
    questions = Events.list_questions(event.id)

    socket
    |> assign(:app, "frontend")
    |> assign(:event, event)
    |> assign(:questions, questions)
  end
end

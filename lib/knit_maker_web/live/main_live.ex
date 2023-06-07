defmodule KnitMakerWeb.MainLive do
  use KnitMakerWeb, :live_view

  alias KnitMaker.{Events, Participants}
  alias KnitMakerWeb.Presence

  @impl true
  def mount(%{"question_id" => question_id} = params, session, socket) do
    socket =
      socket
      |> init_participant(params, session)

    %{questions: questions} = socket.assigns
    idx = Enum.find_index(questions, &(to_string(&1.id) == question_id))

    question = Enum.at(questions, idx)

    Phoenix.PubSub.subscribe(KnitMaker.PubSub, "live-question-#{question.id}")

    socket =
      socket
      |> assign(:question, question)
      |> assign(:prev_question, (idx > 0 && Enum.at(questions, idx - 1)) || nil)
      |> assign(:next_question, Enum.at(questions, idx + 1))
      |> reload_pixel()

    {:ok, socket}
  end

  def mount(params, session, socket) do
    {:ok, init_participant(socket, params, session)}
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

  def handle_event("knit", %{}, socket) do
    {:noreply, redirect(socket, to: ~p"/#{socket.assigns.event.slug}/knitting")}
  end

  def handle_event("download", %{}, socket) do
    {:noreply, redirect(socket, to: ~p"/image/event/#{socket.assigns.event.id}")}
  end

  def handle_event("set-answer", args, socket) do
    {:ok, r} =
      Participants.create_response(
        socket.assigns.question,
        args |> Map.put("participant_id", socket.assigns.participant_id)
      )

    {:noreply, reload_responses(socket)}
  end

  def handle_event("set-pixel", %{"x" => x, "y" => y, "col" => col}, socket) do
    tuple = [DateTime.utc_now() |> to_string, x, y, opposite(col)]

    question = socket.assigns.question

    {:ok, r} =
      Participants.create_response(
        socket.assigns.question,
        %{"participant_id" => socket.assigns.participant_id, "json" => %{"pixels" => [tuple]}},
        fn %{json: %{"pixels" => prev}}, attrs ->
          Map.put(attrs, "json", %{"pixels" => Enum.slice([tuple | prev], 0..5)})
        end
      )

    Phoenix.PubSub.broadcast_from(
      KnitMaker.PubSub,
      self(),
      "live-question-#{question.id}",
      :reload_pixel
    )

    {:noreply, reload_responses(socket) |> reload_pixel()}
  end

  @impl true
  def handle_info(:reload_pixel, socket) do
    {:noreply, reload_pixel(socket)}
  end

  def handle_info(:reload_knitting, socket) do
    {:noreply, reload_knitting(socket)}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, reload_participant_list(socket)}
  end

  defp opposite("0"), do: "1"
  defp opposite("1"), do: "0"

  defp init_participant(socket, params, session) do
    event = Events.get_event_by_slug!(params["slug"])
    questions = Events.list_questions(event.id)

    participant_id = session["participant_id"]

    Presence.track(self(), "event-#{event.id}", participant_id, %{
      "participant_id" => participant_id
    })

    :timer.send_interval(1000, :reload_knitting)

    Phoenix.PubSub.subscribe(KnitMaker.PubSub, "event-#{event.id}")

    socket
    |> assign(:app, "frontend")
    |> assign(:event, event)
    |> assign(:questions, questions)
    |> assign(:participant_id, participant_id)
    |> reload_responses()
    |> reload_knitting()
    |> reload_participant_list()
  end

  defp reload_knitting(socket) do
    {:ok, knitting} = KnitMaker.Knitting.get_knitting(socket.assigns.event.id)
    assign(socket, :knitting, knitting)
  end

  defp reload_participant_list(socket) do
    online_users = Presence.list("event-#{socket.assigns.event.id}") |> Enum.count()
    socket |> assign(:online_users, online_users)
  end

  defp reload_responses(socket) do
    responses =
      Participants.list_responses_by_event_and_participant(
        socket.assigns.event.id,
        socket.assigns.participant_id
      )
      |> Map.new(fn r -> {r.question_id, r} end)

    socket
    |> assign(:responses, responses)
  end

  defp reload_pixel(socket) do
    question = socket.assigns.question

    socket
    |> assign(
      :pixel,
      if question.q_type == "pixel" do
        Participants.get_pixels(
          question.id,
          question.config["width"],
          question.config["height"]
        )
      end
    )
  end
end

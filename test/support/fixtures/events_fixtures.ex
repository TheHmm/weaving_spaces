defmodule KnitMaker.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KnitMaker.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        slug: "a-slug",
        description: "some description",
        image_url: "some image_url",
        name: "some name"
      })
      |> KnitMaker.Events.create_event()

    event
  end

  @doc """
  Generate a question.
  """
  def question_fixture(event \\ nil, attrs \\ %{}) do
    event = event || event_fixture()

    attrs =
      attrs
      |> Enum.into(%{
        name: "question",
        code: "some code",
        config: %{},
        description: "some description",
        rank: 42,
        title: "some title",
        type: "single"
      })

    {:ok, question} = KnitMaker.Events.create_question_for_event(event, attrs)

    question
  end
end

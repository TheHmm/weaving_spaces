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
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        code: "some code",
        config: %{},
        description: "some description",
        rank: 42,
        title: "some title",
        type: "some type"
      })
      |> KnitMaker.Events.create_question()

    question
  end
end

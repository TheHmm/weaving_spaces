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
end

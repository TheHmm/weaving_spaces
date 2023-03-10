defmodule KnitMaker.ParticipantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KnitMaker.Participants` context.
  """

  @doc """
  Generate a response.
  """
  def response_fixture(question, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        json: %{},
        participant_id: "some participant_id",
        text: "some text",
        value: 42
      })

    {:ok, response} = KnitMaker.Participants.create_response(question, attrs)

    response
  end
end

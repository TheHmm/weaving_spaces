defmodule KnitMaker.Participants.Response do
  use Ecto.Schema
  import Ecto.Changeset

  alias KnitMaker.Events.{Event, Question}

  schema "responses" do
    field :json, :map
    field :participant_id, :string
    field :text, :string
    field :value, :integer

    belongs_to :event, Event
    belongs_to :question, Question

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:value, :participant_id, :text, :json])
    |> validate_required([:participant_id, :event_id, :question_id])
    |> unique_constraint(:participant_id,
      name: :responses_event_id_question_id_participant_id_index
    )
  end
end

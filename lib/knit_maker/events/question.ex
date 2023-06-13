defmodule KnitMaker.Events.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias KnitMaker.Events.Event

  schema "questions" do
    field(:description, :string)
    field(:rank, :integer)
    field(:title, :string)
    field(:q_config, :map, default: %{})
    field(:q_type, :string, default: "choices")

    field(:v_config, :map, default: %{})
    field(:v_type, :string, default: "skip")

    belongs_to(:event, Event)

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:title, :rank, :q_type, :v_type, :description])
    |> json_decode(:q_config, attrs["q_config"] || attrs[:q_config])
    |> json_decode(:v_config, attrs["v_config"] || attrs[:v_config])
    |> validate_required([:title, :rank, :v_type, :q_type])
    |> validate_inclusion(:q_type, q_types())
    |> validate_inclusion(:v_type, v_types())
  end

  defp json_decode(cs, field, value) do
    case value do
      "{" <> _ = json ->
        put_change(cs, field, Jason.decode!(json))

      %{} = map ->
        put_change(cs, field, map)

      _ ->
        cs
    end
  end

  def q_types() do
    ~w(choices choices-2column choices-gradient pixel)
  end

  def v_types() do
    #    ~w(emoji patterns-all patterns-1 patterns-2 patterns-3 patterns-4 gridfill gridfill-double textbars textbars-single border-count pixel skip)
    ~w(emoji patterns-all gridfill gridfill-double border-count pixel skip textbars textbar)
  end
end

defmodule KnitMaker.Events.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :name, :string

    field :code, :string
    field :config, :map, default: %{}
    field :description, :string
    field :rank, :integer
    field :title, :string
    field :type, :string

    belongs_to :event, KnitMaker.Events.Event

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:title, :name, :rank, :type, :description, :code])
    |> json_decode(:config, attrs["config"] || attrs[:config])
    |> validate_required([:title, :name, :rank, :type])
    |> validate_inclusion(:type, types())
    |> validate_format(:name, ~r/^[a-z][a-z0-9_]*$/)
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

  def types() do
    ~w(choices choices-2column choices-gradient pixel)
  end
end

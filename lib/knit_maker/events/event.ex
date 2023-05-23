defmodule KnitMaker.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias KnitMaker.Events.Question

  schema "events" do
    field(:slug, :string)
    field(:name, :string)
    field(:description, :string)
    field(:image_url, :string)

    has_many(:questions, Question)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :slug, :description, :image_url])
    |> cast_assoc(:questions)
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> unique_constraint(:slug, name: :events_slug)
  end

  def raw(event) do
    e = mappify(event)
    Map.put(e, :questions, Enum.map(e.questions, &mappify/1))
  end

  def mappify(event) do
    Map.from_struct(event) |> Map.drop(~w(id inserted_at updated_at __meta__)a)
  end
end

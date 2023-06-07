defmodule KnitMaker.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias KnitMaker.Events.Question

  schema "events" do
    field(:slug, :string)
    field(:name, :string)
    field(:description, :string)
    field(:image_url, :string)

    field(:knitting_width, :integer, default: 60)
    field(:knitting_fg, :string, default: "#ffcc00")
    field(:knitting_bg, :string, default: "#111111")

    has_many(:questions, Question)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :slug,
      :description,
      :image_url,
      :knitting_bg,
      :knitting_fg,
      :knitting_width
    ])
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
    Map.from_struct(event) |> Map.drop(~w(id inserted_at updated_at __meta__ event)a)
  end
end

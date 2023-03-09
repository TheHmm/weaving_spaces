defmodule KnitMaker.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :slug, :description, :image_url])
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> unique_constraint(:slug, name: :events_slug)
  end
end

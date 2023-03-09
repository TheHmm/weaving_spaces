defmodule KnitMaker.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :slug, :string
      add :name, :string
      add :description, :string
      add :image_url, :string

      timestamps()
    end

    create(unique_index(:events, [:slug], name: :events_slug))
  end
end

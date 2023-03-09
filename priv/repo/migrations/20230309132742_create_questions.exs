defmodule KnitMaker.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :title, :string
      add :rank, :integer
      add :type, :string
      add :description, :string
      add :config, :map
      add :code, :string
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:questions, [:event_id])
  end
end

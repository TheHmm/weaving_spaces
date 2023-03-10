defmodule KnitMaker.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :participant_id, :string
      add :value, :integer
      add :text, :string
      add :json, :map

      add :event_id, references(:events, on_delete: :nothing)
      add :question_id, references(:questions, on_delete: :nothing)

      timestamps()
    end

    create index(:responses, [:event_id])
    create index(:responses, [:question_id])
    create unique_index(:responses, [:event_id, :question_id, :participant_id])
  end
end

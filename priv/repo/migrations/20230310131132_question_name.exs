defmodule KnitMaker.Repo.Migrations.QuestionName do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :name, :string
    end

    flush()

    execute("UPDATE questions SET name = 'q' || CAST(id AS TEXT)")
  end
end

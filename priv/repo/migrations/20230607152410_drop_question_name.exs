defmodule KnitMaker.Repo.Migrations.DropQuestionName do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      remove(:name)
    end
  end
end

defmodule KnitMaker.Repo.Migrations.QuestionConfig do
  use Ecto.Migration

  def change do
    execute("alter table questions rename config to q_config")

    alter table(:questions) do
      add :v_config, :map
    end

    execute("update questions set v_config = '{}'")
  end
end

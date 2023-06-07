defmodule KnitMaker.Repo.Migrations.QuestionType do
  use Ecto.Migration

  def change do
    execute("alter table questions rename type to q_type")

    alter table(:questions) do
      add(:v_type, :string)
    end

    execute("update questions set v_type = 'skip'")
  end
end

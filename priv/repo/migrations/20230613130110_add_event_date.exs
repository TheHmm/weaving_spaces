defmodule KnitMaker.Repo.Migrations.AddEventDate do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :date, :string
    end

    flush()

    execute("update events set date = description")
  end
end

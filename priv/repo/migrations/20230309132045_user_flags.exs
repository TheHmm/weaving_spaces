defmodule KnitMaker.Repo.Migrations.UserFlags do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_admin, :boolean, default: false
      add :is_anonymous, :boolean, default: false
    end
  end
end

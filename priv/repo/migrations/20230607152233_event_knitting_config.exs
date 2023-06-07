defmodule KnitMaker.Repo.Migrations.EventKnittingConfig do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add(:knitting_width, :integer)
      add(:knitting_fg, :string)
      add(:knitting_bg, :string)
    end

    execute(
      "UPDATE events SET knitting_width = 60, knitting_fg = '#ffcc00', knitting_bg = '#000000'"
    )
  end
end

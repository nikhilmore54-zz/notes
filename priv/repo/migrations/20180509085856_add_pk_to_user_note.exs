defmodule Notes.Repo.Migrations.AddPkToUserNote do
  use Ecto.Migration

  def up do
    alter table (:user_note) do
      remove :user_id
      add :user_id, :integer
      remove :note_id
      add :note_id, :integer
    end
  end

  def down do
    alter table (:user_note) do
      remove :user_id
      add :user_id, :integer
      remove :note_id
      add :note_id, :integer
    end
  end
end

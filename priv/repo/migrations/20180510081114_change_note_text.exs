defmodule Notes.Repo.Migrations.ChangeNoteText do
  use Ecto.Migration

  def change do
    alter table (:notes) do
      modify :note, :text
    end
  end
end

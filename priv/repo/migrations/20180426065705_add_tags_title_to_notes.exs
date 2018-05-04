defmodule Notes.Repo.Migrations.AddTagsTitleToNotes do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :title, :string
      add :tags, :string
    end
  end
end

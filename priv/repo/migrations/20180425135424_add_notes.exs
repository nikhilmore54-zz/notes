defmodule Notes.Repo.Migrations.AddNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :note, :string
    end
  end
end

defmodule Notes.Repo.Migrations.NotesAndUsersAssociation do
  use Ecto.Migration

  def change do
    create table (:roles) do
      add :role, :string
    end

    create table(:user_note, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :note_id, references(:notes, on_delete: :delete_all)
      add :role_id, references(:roles)
      add :shared_by, references(:users, on_delete: :nothing)
    end

    create index(:user_note, [:note_id, :user_id], name: :note_user_index)
    create index(:user_note, [:note_id, :shared_by], name: :note_shared_by_index)
  end
end

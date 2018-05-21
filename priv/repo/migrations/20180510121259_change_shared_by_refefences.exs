defmodule Notes.Repo.Migrations.ChangeSharedByRefefences do
  use Ecto.Migration

  def up do
    alter table (:user_note) do
      modify :shared_by, :integer
    end
  end

  def down do
    add :shared_by, references(:users, on_delete: :nothing)
  end
end

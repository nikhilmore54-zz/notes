defmodule Notes.Repo.Migrations.AddCreatorModifier do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      add :user_id, :integer
      add :modifier, :integer
    end
  end
end

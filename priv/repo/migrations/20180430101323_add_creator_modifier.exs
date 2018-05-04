defmodule Notes.Repo.Migrations.AddCreatorModifier do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      modify :creator, :string
      modify :modifier, :string
    end
  end
end

defmodule Notes.UserNote do
  use Notes.Web, :model

  @primary_key false

  schema "user_note" do
    field :user_id, :integer, primary_key: true
    field :note_id, :integer, primary_key: true
    field :role_id, :integer
    field :shared_by, :integer

  end

  def changeset(struct, params \\ %{}) do
  	ch = struct
  	|> cast(params, [:user_id, :note_id, :role_id, :shared_by])
    |> cast(params, [:shared_by])
  end

  def note_shared_with(params) do
    (from u in Notes.UserNote,
              where: u.shared_by == ^params.user_id,
              where: u.note_id   == ^params.note_id,
              where: u.role_id   >  ^params.role_id,
              select: u.user_id)
  end
end

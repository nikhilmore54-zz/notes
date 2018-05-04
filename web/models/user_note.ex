defmodule Notes.UserNote do
  use Notes.Web, :model

  schema "user_note" do
    field :user_id, :integer
    field :note_id, :integer
    field :role_id, :integer
    field :shared_by, :integer
  end

  def changeset(struct, params \\ %{}) do
  	ch = struct
  	|> cast(params, [])

  end
end

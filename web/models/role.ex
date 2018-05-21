defmodule Notes.Role do
  use Notes.Web, :model

  schema "roles" do
    field :role, :string

    many_to_many :notes, Notes.Note, join_through: "user_note"
    many_to_many :users, Notes.User, join_through: "user_note"

    # has_many(:notes, Notes.Note)
    # has_many(:users, Notes.User)
  end

end

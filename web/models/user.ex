defmodule Notes.User do
  use Notes.Web, :model

  schema "users" do
    field :email, :string
    field :crypted_password, :string

    timestamps()

    many_to_many :notes, Notes.Note, join_through: "user_note"
    many_to_many :roles, Notes.Role, join_through: "user_note"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :crypted_password])
    |> validate_required([:email, :crypted_password])
    |> Notes.Repo.preload(:notes)
    |> put_assoc(:notes, params["note_id"])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:crypted_password, min: 5)
  end
end

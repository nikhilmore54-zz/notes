defmodule Notes.Note do
  use Notes.Web, :model

  schema "notes" do
    field :title, :string
  	field :note, :string
    field :tags, :string

    field :creator, :string
    field :modifier, :string

    many_to_many :users, Notes.User, join_through: "user_note"
    many_to_many :roles, Notes.Role, join_through: "user_note"
  end

  def changeset(struct, params \\ %{}) do
  	ch = struct
  	|> cast(params, [:title, :note, :tags, :creator, :modifier])
  	|> validate_required([:title, :note])
    |> Notes.Repo.preload(:users)
    |> put_assoc(:users, params["user_id"])

    put_change(ch, :tags, extract_tags(ch))
  end

  defp extract_tags(changeset) do
    text = get_change(changeset, :note) |> to_string
    Regex.scan(~r/#([a-zA-Z0-9]*)/, text)
            |> Enum.map(fn[_a, b] -> b end)
            |> Enum.reject(& &1 == "")
            |> List.flatten
            |> Enum.join(" ")
  end
end

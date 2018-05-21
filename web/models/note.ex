defmodule Notes.Note do
  use Notes.Web, :model
  require IEx

  schema "notes" do
    field :title, :string
  	field :note, :string
    field :tags, :string

    field :user_id, :integer
    field :modifier, :integer

    # many_to_many :users, Notes.User, join_through: "user_note"
    # many_to_many :roles, Notes.Role, join_through: "user_note"

    # has_many(:users, Notes.User)
    # has_many :roles, Notes.Role

    #
  end

  def changeset(struct, params \\ %{}) do
  	ch = struct
  	|> cast(params, [:title, :note, :tags, :modifier, :user_id])
    |> validate_required([:title, :note])
    extract_tags(ch)
  end

  defp extract_tags(changeset) do
    text = get_change(changeset, :note)
    if text == nil do
      changeset
    else
      text = to_string(text)
      string = Regex.scan(~r/#([a-zA-Z0-9]*)/, text)
              |> Enum.map(fn[_a, b] -> b end)
              |> Enum.reject(& &1 == "")
              |> Enum.uniq
              |> List.flatten
              |> Enum.join(" ")
              |> String.trim
      put_change(changeset, :tags, string)
    end
  end

  def get_note_title_for_user(user_id) do
    query =
    """
    SELECT u.note_id, u.role_id, n.title
    FROM user_note as u, notes as n
    WHERE u.user_id = $1
    AND u.note_id = n.id
    AND u.role_id > 0
    """
    Ecto.Adapters.SQL.query!(Notes.Repo, query, [user_id])
  end

  def count_tags(tag, user_id) do
    tag_count = (Notes.Repo.one(from note in subquery(get_notes_by_user(user_id)),
          select: count(note.id),
          where: ilike(note.tags, ^"#{tag}")))
    ["#{tag}", tag_count]
  end

  def find_user_notes(user_id, note_id) do
    (from u in Notes.UserNote,
        where: u.user_id == ^user_id,
        where: u.note_id == ^note_id)
  end

  def find_shared_with(user_id, note_id, role_id) do
    (from u in Notes.UserNote,
    where: u.shared_by == ^user_id,
    where: u.note_id   == ^note_id,
    where: u.role_id   >  ^role_id,
    select: u.user_id)
    |> Notes.Repo.all

  end

  def sanitize_html(note) do
    Phoenix.HTML.Format.text_to_html(note)
  end

  def get_notes_by_user(user_id) do
    (from u in Notes.User,
    join: n in assoc(u, :notes),
    where: u.id == ^user_id,
    select: n)
  end
end

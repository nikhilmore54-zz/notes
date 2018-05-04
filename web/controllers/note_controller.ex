defmodule Notes.NoteController do
  use Notes.Web, :controller
  # import Ecto.Changeset
  alias Notes.Note
  alias Notes.User
  alias Notes.Role

  def index(conn, _params) do
    notes = Repo.all(Note)

    render conn, "index.html", notes: notes
  end

  def new(conn, _params) do
    if curr_user = get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      changeset = Note.changeset(%Note{}, %{})
      render conn, "new.html", changeset: changeset
    end
  end

  def create(conn, %{"note" => note}) do
    if curr_user = get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      changeset = Note.changeset(%Note{}, note)
      |> Ecto.Changeset.put_change(:creator, curr_user |> to_string)

      case Repo.insert(changeset) do
        {:ok, _note} ->
          conn
          |> put_flash(:info, "Note Created")
          |> redirect(to: note_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    end
  end

  def show(conn,  %{"id" => note_id}) do
    note = Repo.get(Note, note_id)
    tag_count_list = case note.tags do
      nil  ->
        nil
      _   ->
      for tag <- String.split(note.tags, " ") do
        tag_count = (Repo.one(from note in Note,
        select: count(note.id),
        # where: note.tags in ["trend"]))
        where: ilike(note.tags, ^"%#{tag}%")))
        ["#{tag}", tag_count]
      end
    end
    render conn, "show.html", note: note, tag_list: tag_count_list
  end

  def edit(conn, %{"id" => note_id}) do
    if get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      note = Repo.get(Note, note_id)
      changeset = Note.changeset(note)
      render conn, "edit.html", changeset: changeset, note: note
    end
  end

  def update(conn, %{"id" => note_id, "note" => note}) do
    if curr_user = get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      old_note = Repo.get(Note, note_id)
      changeset = Note.changeset(old_note, note)
      |> Ecto.Changeset.put_change(:modifier, curr_user |> to_string)
      case Repo.update(changeset) do
        {:ok, _note} ->
          conn
          |> put_flash(:info, "Note Updated")
          |> redirect(to: note_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    end
  end

  def delete(conn, %{"id" => note_id}) do
    if get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      Repo.get!(Note, note_id) |> Repo.delete!

      conn
      |> put_flash(:info, "Note Deleted")
      |> redirect(to: note_path(conn, :index))
    end
  end

  def share(conn, %{"id" => note_id}) do
    if curr_user = get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      users = Repo.all(User)
      roles = Repo.all(Role)
      note = Repo.get(Note, note_id)
      changeset = Note.changeset(note)
      render conn, "share.html", changeset: changeset, note: note, users: users, roles: roles
    end
  end

  def allow(conn, params) do
    IO.puts "~~~~Allow~~~~"
    IO.inspect params
    IO.puts "~~~~"
    send_resp(conn, 200, "FOO")
		|> halt
  end
end

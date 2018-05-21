defmodule Notes.NoteController do
  use Notes.Web, :controller
  alias Notes.Note
  alias Notes.UserNote
  alias Notes.NoteHelper

  require IEx

  def index(conn, _params) do
    curr_user = get_session(conn, :current_user)
    if curr_user == nil do
      put_flash(conn, :error_handler, "Login first")
      render conn, "index.html"
    else
      user_note = Note.get_note_title_for_user(curr_user.id)
      render conn, "index.html", notes: user_note.rows
    end
  end

  def new(conn, _params) do
    if get_session(conn, :current_user) == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      changeset =
       get_session(conn, :current_user)
        |> build_assoc(:notes)
        |> Note.changeset()

      render conn, "new.html", changeset: changeset
    end
  end

  def create(conn, %{"note" => note}) do
    curr_user = get_session(conn, :current_user)
    if curr_user == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      changeset =
        curr_user
        |> build_assoc(:notes)
        |> Note.changeset(%{note: note["note"], title: note["title"], user_id: curr_user.id})

      case Repo.insert(changeset) do
        {:ok, note} ->
          changeset1 =
          UserNote.changeset(%UserNote{},
                            %{shared_by: 0, note_id: note.id, role_id: 3, user_id: curr_user.id})
          case Repo.insert_or_update(changeset1) do
            {:ok, user_note} ->
              user_note
            {:error, _changeset} ->
              conn
              |> put_flash(:error, "Error in sharing the Note")
              |> redirect(to: note_path(conn, :index))
          end
          conn
          |> put_flash(:info, "Note Created")
          |> redirect(to: note_path(conn, :index))
        {:error, changeset} ->
          render conn, "new.html", changeset: changeset
      end
    end
  end

  def show(conn, %{"id" => note_id, "role" =>role_string } ) do
    note = Repo.get(Note, note_id)
    role = String.to_integer(role_string)
    if note == nil do
      redirect(conn, to: note_path(conn, :index))
    else
      tag_count_list =
      case note.tags do
        nil  ->
          nil
        _   ->
        for tag <- String.split(note.tags, " ") do
          unless String.length(tag) == 0,
            do: Note.count_tags(tag, get_session(conn, :current_user).id)
        end
      end
      render conn, "show.html", note: note, tag_list: tag_count_list, role: role
    end
  end

  def edit(conn, %{"id" => note_id, "role" => role}) do
    if role < 2 do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      note = Repo.get(Note, note_id)
      changeset = Note.changeset(note)
      render conn, "edit.html", changeset: changeset, note: note, role: [role |> String.to_integer]
    end
  end

  def update(conn, %{"id" => note_id, "note" => note, "role" => [role]} = _params) do
    curr_user = get_session(conn, :current_user)
    if curr_user == nil do
      conn
      |> put_flash(:error, "You dont have sufficient rights to perform this operation")
      |> redirect(to: note_path(conn, :index))
    else
      old_note = Repo.get(Note, note_id)
      changeset = Note.changeset(old_note, note)
      |> Ecto.Changeset.put_change(:modifier, curr_user.id)
      case Repo.update(changeset) do
        {:ok, _note} ->
          conn
          |> put_flash(:info, "Note edited successfully")
          |> redirect(to: note_path(conn, :index))
        {:error, changeset} ->
          render conn, "edit.html", changeset: changeset, note: %Note{}, role: [role |> String.to_integer]
      end
    end
  end

  def delete(conn, %{"id" => note_id} = _params) do
    curr_user = get_session(conn, :current_user)
    if curr_user == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      Repo.get!(Note, note_id) |> Repo.delete!

      (from u in UserNote,
      where: u.note_id == ^note_id)
      |> Repo.delete_all

      conn
      |> put_flash(:info, "Note Deleted")
      |> redirect(to: note_path(conn, :index))
    end
  end

  def share(conn, %{"id" => note_id, "role" => role}) do
    curr_user = get_session(conn, :current_user)
    if curr_user == nil do
      conn
      |> put_flash(:error, "Login first")
      |> redirect(to: note_path(conn, :index))
    else
      users = Repo.all from u in Notes.User,
              where: u.id != 0
      roles = Repo.all from r in Notes.Role,
              where: r.id <= ^role
      note = Repo.get(Note, note_id)
      changeset = Note.changeset(note)
      render conn, "share.html", changeset: changeset, note: note, users: users,
                    roles: roles, shared_by: curr_user.id
    end
  end

#####   Share Notes function  ####

  def share_notes(conn, %{"id" => note_id,
            "note" => %{"roles" => role_id, "users" => user_id,
            "shared_by" => shared_by}} = params) do

    curr_user = get_session(conn, :current_user)

    shared_by =
    if shared_by == nil do
      curr_user.id
    else
      shared_by
    end
    if user_id == to_string(shared_by)do
      conn
      |> put_flash(:error, "You cannot share a note with yourself")
      |> redirect(to: note_path(conn, :index))
    else
      query = Note.find_user_notes(user_id, note_id)
      # IEx.pry
      changeset =
      case Repo.all(query) do
        [] -> IO.puts "empty case"

        # IEx.pry
        UserNote.changeset(%UserNote{}, %{shared_by: shared_by, note_id: note_id,
                            role_id: role_id, user_id: user_id})

        user_notes ->
          [user_note | _others ] = user_notes
          if to_string(user_note.shared_by) == shared_by or user_note.role_id == 0 do
            NoteHelper.get_changeset(conn, user_note, user_id, role_id, note_id, shared_by)
          else
            conn
            |> put_flash(:error, "Note already shared with this user")
            |> redirect(to: note_path(conn, :index))
          end
      end

      # IEx.pry

      case Repo.insert_or_update(changeset) do
        {:ok, _note} ->
          conn
          |> put_flash(:info, "Note Shared Successfully")
          |> redirect(to: note_path(conn, :index))
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Error in sharing the Note")
          |> redirect(to: note_path(conn, :index))
      end
    end
  end
end

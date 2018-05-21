defmodule Notes.NoteHelper do
  import IEx

  def get_changeset(conn, user_note, user_id, role_id, note_id, shared_by) do
    unless is_binary(user_id) do
      user_id = to_string(user_id)
    end

    # create a list of all the notes shared by the current user

    shared_with = Notes.Note.find_shared_with(user_id, note_id, role_id)

    # if the current privileges are greater than the new ones, iterate on the list to modify the privileges

    for u_id <- shared_with do
      input = %{"id" => note_id,
      "note" => %{"roles" => role_id,
      "users" => u_id,
      "shared_by" => user_id |> to_string }}

      Notes.NoteController.share_notes(conn, input)
    end
    Notes.UserNote.changeset(user_note, %{shared_by: shared_by, role_id: role_id})
  end
end

defmodule Notes.SessionController do
  use Notes.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, session_params) do
    case Notes.Session.login(session_params, Notes.Repo) do
      {:ok, user} ->
        # IO.inspect assign(conn, :current_user, user)
        conn
        |> put_session(:current_user, user)
        |> put_flash(:info, "Logged in")
        |> redirect(to: "/")
      {:error, msg} ->
        IO.inspect msg
        conn
        |> put_flash(:info, msg)
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> render("new.html")
  end
end

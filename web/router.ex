defmodule Notes.Router do
  use Notes.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser # Use the default browser stack

    get    "/login",  Notes.SessionController, :new
    post   "/login",  Notes.SessionController, :create
    delete "/logout", Notes.SessionController, :delete

    get    "/:id/share", Notes.NoteController, :share
    put   "/:id/share", Notes.NoteController, :allow

    resources "/", Notes.NoteController
    resources "/registrations", Notes.RegistrationController, only: [:new, :create]
  end




  # Other scopes may use custom stacks.
  # scope "/api", Notes do
  #   pipe_through :api
  # end
end

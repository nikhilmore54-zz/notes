defmodule Notes.Registration do
  import Ecto.Changeset, only: [put_change: 3]

  def create(changeset, repo) do
    # IO.inspect changeset.params["crypted_password"]
    changeset
    # |> put_change(:crypted_password, hashed_password(changeset.params["password"]))
    |> repo.insert()
  end

  # defp hashed_password(password) do
  #   Comeonin.Bcrypt.hashpwsalt(password)
  # end
end

defmodule Rumbl.UsersController do
  use Rumbl.Web, :controller

  def index(conn, _params) do

    users = Repo.all(Rumbl.User)
    IO.inspect users

    render conn, "users.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Rumbl.User, id)
    render conn, "show.html", user: user
  end
end

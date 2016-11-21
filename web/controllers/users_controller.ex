defmodule Rumbl.UsersController do
  use Rumbl.Web, :controller

  def getUsers(conn, _params) do

    users = Repo.all(Rumbl.User)
    IO.inspect users

    render conn, "users.html", users: users
  end
end

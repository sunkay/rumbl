defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def delete(conn, _) do
    conn
    |> Rumbl.Plugs.Auth.logout
    |> redirect(to: user_path(conn, :index))
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case Rumbl.Plugs.Auth.login_by_username_pass(conn, username, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back")
        |> redirect(to: user_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:info, "Invalid Username & password combination")
        |> render "new.html"
    end
  end

end

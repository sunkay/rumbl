defmodule AuthPlugTest do
  use Rumbl.ConnCase
  alias Rumbl.Plugs.RequireAuth
  alias Rumbl.Plugs.Auth
  alias Rumbl.Repo

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "RequireAuth halts if there is no current_user assigned", %{conn: conn} do
    conn = RequireAuth.call(conn, [])
    assert conn.halted
  end

  test "RequireAuth continues if the current_user assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> RequireAuth.call([])
    refute conn.halted
  end

  test "Test login user puts the user id in the sesion Auth Plug",
        %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      |> send_resp(:ok, "")

      next_conn = get(login_conn, "/")
      assert get_session(next_conn, :user_id) == 123
  end

  test "Test logout drops the session",
        %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    assert get_session(next_conn, :user_id) == nil
  end

  test "test call gets user_id from session and puts user into assigns",
    %{conn: conn} do
      user = insert_user()

      conn =
        conn
        |> put_session(:user_id, user.id)
        |> Auth.call(Repo)

      assert conn.assigns.current_user.id == user.id
    end

  test "test call with no user_id in session assigns nil for current_user",
    %{conn: conn} do

      conn = Auth.call(conn, Repo)
      assert conn.assigns.current_user == nil
    end

  test "test login with a valid username and pass",
    %{conn: conn} do
      user = insert_user(username: "mesty", password: "secret")
      {:ok, conn} = Auth.login_by_username_pass(conn, "mesty", "secret", repo: Repo)
      assert conn.assigns.current_user.username == user.username
    end

  test "test invalid password will return an unauthorized ",
    %{conn: conn} do
      _ = insert_user(username: "mesty", password: "secret")

      {error, unauth, _conn} =
         Auth.login_by_username_pass(conn, "mesty", "wrong", repo: Repo)
      assert error == :error
      assert unauth == :unauthorized
    end

  test "test login with no user in the db returns not_found",
    %{conn: conn} do

      assert {:error, :not_found, _conn} = Auth.login_by_username_pass(conn, "mesty", "secret", repo: Repo)
    end

end

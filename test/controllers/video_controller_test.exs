defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  test "Redirection happens on routes with no user session", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end

  setup  do
    user = insert_user(username: "max")
    conn = assign(conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "Lists all user's videos on index route", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "funny cats")
    other_video = insert_video(user, title: "another video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200)
  end

end

defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  setup  %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)

      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

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

  @tag login_as: "max"
  test "list all videos on route index", %{conn: conn, user: user} do
    {:ok, user_video} = insert_video(user)
    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing videos"
    assert String.contains?(conn.resp_body, user_video.title)
  end

end

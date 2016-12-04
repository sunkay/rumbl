defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  alias Rumbl.Video

  @valid_attrs  %{url: "http://youtube.com", title: "XYZ", description: "Testing"}
  @update_attrs  %{url: "http://youtube.com", title: "UpdatedTitle", description: "UpdatedDesc"}
  @invalid_attrs  %{url: ""}

  setup  %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)

      # load categories
      Repo.insert!(%Rumbl.Category{name: "Action", id: 1})

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
    {:ok, user_video} = insert_video(user, @valid_attrs)
    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing videos"
    assert String.contains?(conn.resp_body, user_video.title)
  end

  @tag login_as: "max"
  test "create a user video with valid attrs and redirect", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "max"
  test "create a user video with INVALID attrs and redirect", %{conn: conn, user: _user} do
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "New video"
    assert html_response(conn, 200) =~ "Oops, something went wrong"
  end

  @tag login_as: "max"
  test "update user video info with valid_attrs", %{conn: conn, user: user} do
    {:ok, user_video} = insert_video(user, @valid_attrs)

    conn = put conn, video_path(conn, :update, user_video), video: @update_attrs
    assert redirected_to(conn) == video_path(conn, :show, user_video)
  end

  @tag login_as: "max"
  test "update user video erros with invalid_attrs", %{conn: conn, user: user} do
    {:ok, user_video} = insert_video(user, @valid_attrs)

    conn = put conn, video_path(conn, :update, user_video), video: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "max"
  test "deletes user video", %{conn: conn, user: user} do
    {:ok, user_video} = insert_video(user, @valid_attrs)

    conn = delete conn, video_path(conn, :delete, user_video)
    assert redirected_to(conn) == video_path(conn, :index)
    refute Repo.get(Video, user_video.id)
  end

end

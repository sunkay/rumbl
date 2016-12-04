defmodule Rumbl.VideoViewTest do
  use Rumbl.ConnCase, async: true
  import Phoenix.View

  test "renders index.html", %{conn: conn} do
    videos = [%Rumbl.Video{id: "1", title: "dogs", category_id: 1},
              %Rumbl.Video{id: "2", title: "cats", category_id: 1}]

    categories = [{"Action", 1}]
    content = render_to_string(Rumbl.VideoView, "index.html",
                                conn: conn, videos: videos, categories: categories)

    assert String.contains?(content, "Listing videos")
    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end


end

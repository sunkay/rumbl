defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "somename",
      username: "test#{:rand.uniform(10)}",
      password: "121212",
      }, attrs)

      %Rumbl.User{}
      |> Rumbl.User.registration_changeset(changes)
      |> Repo.insert!()
  end

  def insert_video(user) do
    cat = Repo.insert!(%Rumbl.Category{name: "Action", id: 1})
    changeset =
    user
    |> Ecto.build_assoc(:videos, category_id: cat.id)
    |> Rumbl.Video.changeset(%{"title" => "xyz", "url" => "urlval", "description" => "desc"})

    Repo.insert(changeset)
  end


end

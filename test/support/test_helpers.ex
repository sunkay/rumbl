defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "somename",
      username: "test#{:random.uniform(10)}",
      password: "121212",
      }, attrs)

      %Rumbl.User{}
      |> Rumbl.User.registration_changeset(changes)
      |> Repo.insert!()
  end

  def insert_video(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos, attrs)
    |> Repo.insert!()
  end

end

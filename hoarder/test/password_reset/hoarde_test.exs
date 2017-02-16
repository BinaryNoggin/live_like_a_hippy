defmodule PasswordResetHoardTest do
  use Hoarder.TestCase, async: false
  alias PasswordResetHoard
  alias Hoarder.User
  alias Hoarder.Repo

  setup do
    pid = GenServer.whereis(PasswordResetHoard)
    Ecto.Adapters.SQL.Sandbox.allow(Hoarder.Repo, self(), pid)
    :sys.replace_state(PasswordResetHoard, fn(_) -> %{} end)
    :ok
  end

  test "adding a user that exists" do
    email = "real@example.com"
    Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))

    PasswordResetHoard.add(email)
    user = Repo.get_by(User, email: email)

    [found_user | []] = Map.values(:sys.get_state(PasswordResetHoard))

    assert found_user == user
  end

  test "removing a reset" do
    :sys.replace_state(PasswordResetHoard, fn -> %{a: 1} end)

    PasswordResetHoard.remove(:a)

    assert %{} == :sys.get_state(PasswordResetHoard)
  end
end

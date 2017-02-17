defmodule PasswordResetHoardTest do
  use Hoarder.TestCase, async: false
  alias PasswordResetHoard
  alias Hoarder.User
  alias Hoarder.Repo

  setup do
    {:ok, pid} = PasswordResetHoard.start_link(name: __MODULE__)
    Ecto.Adapters.SQL.Sandbox.allow(Hoarder.Repo, self(), pid)
    :ok
  end

  test "adding a user that exists" do
    email = "real@example.com"
    Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))

    PasswordResetHoard.add(email, __MODULE__)
    user = Repo.get_by(User, email: email)

    [found_user | []] = Map.values(:sys.get_state(__MODULE__))

    assert found_user == user
  end

  test "removing a reset" do
    :sys.replace_state(__MODULE__, fn(_) -> %{a: 1} end)

    PasswordResetHoard.remove(:a, __MODULE__)

    assert %{} == :sys.get_state(__MODULE__)
  end

  test "get a user that by the reset token" do
    :sys.replace_state(__MODULE__, fn(_) -> %{a: :user} end)

    assert {:ok, :user} == PasswordResetHoard.get_user(:a, __MODULE__)
  end

  test "trying to get a user that is not in the reset system" do
    assert :error == PasswordResetHoard.get_user(:invalid, __MODULE__)
  end
end

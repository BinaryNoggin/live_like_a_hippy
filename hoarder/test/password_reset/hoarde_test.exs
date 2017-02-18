defmodule PasswordResetHoardTest do
  use Hoarder.TestCase, async: false
  alias PasswordResetHoard
  alias Hoarder.User
  alias Hoarder.Repo
  @process_id __MODULE__

  setup do
    {:ok, pid} = PasswordResetHoard.start_link(name: @process_id)
    Ecto.Adapters.SQL.Sandbox.allow(Hoarder.Repo, self(), pid)
    :ok
  end

  test "adding a user that exists" do
    email = "real@example.com"
    Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))

    PasswordResetHoard.add(email, @process_id)
    user = Repo.get_by(User, email: email)

    [found_user | []] = Map.values(:sys.get_state(@process_id))

    assert found_user == user
  end

  test "adding a user that doesn't exist" do
    PasswordResetHoard.add("not_here@example.com", @process_id)

    assert %{} == :sys.get_state(@process_id)
  end

  test "removing a reset" do
    :sys.replace_state(@process_id, fn(_) -> %{a: 1} end)

    PasswordResetHoard.remove(:a, @process_id)

    assert %{} == :sys.get_state(@process_id)
  end

  test "get a user that by the reset token" do
    :sys.replace_state(@process_id, fn(_) -> %{a: :user} end)

    assert {:ok, :user} == PasswordResetHoard.get_user(:a, @process_id)
  end

  test "trying to get a user that is not in the system" do
    assert :error == PasswordResetHoard.get_user(:invalid, @process_id)
  end
end

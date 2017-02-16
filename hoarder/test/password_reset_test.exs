defmodule Hoarder.PasswordResetTest do
  use Hoarder.TestCase, async: false
  alias Hoarder.PasswordReset
  alias Hoarder.User

  setup do
    pid = GenServer.whereis(PasswordResetHoard)
    Ecto.Adapters.SQL.Sandbox.allow(Hoarder.Repo, self(), pid)
    :ok
  end

  describe "starting with an email that doesn't exist" do
    test "has default secure response" do
      assert :ok = PasswordReset.start("fake@example.com")
      sync_hoard()
    end
  end

  describe "starting with an email that is in the system" do
    setup do
      clear_reset_cache()
      email = "real@example.com"

      user = Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))
      response = PasswordReset.start(user.email)

      %{user: user, response: response}
    end

    test "has default secure response", %{response: response} do
      assert :ok = response
      sync_hoard()
    end

    test "the user is assigned a reset tokoen", %{user: %{id: id}} do
      user = Repo.get(User, id)
      hoard_state = :sys.get_state(PasswordResetHoard)

      [token | []] = Map.keys(hoard_state)

      assert Map.get(hoard_state, token) == user
      sync_hoard()
    end
  end

  describe "resetting with an invalid token" do
    test "responds with :error" do
      assert :error == PasswordReset.complete("invalid_token", "new password")
    end
  end

  describe "resetting with a valid token" do
    setup do
      email = "real@example.com"

      user = Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))

      set_cache_state %{"valid_token" => user}

      %{user: user}
    end

    test "changes the password and valid password", %{user: %{password: original_password, id: id}} do
      PasswordReset.complete("valid_token", "new password")

      user = Repo.get(User, id)

      refute original_password == user.password
    end

    test "does not change the password with an invalid password", %{user: %{password: original_password, id: id}} do
      PasswordReset.complete("valid_token", "invalid")

      user = Repo.get(User, id)

      assert original_password == user.password
    end

    test "returns invalid changeset" do
       {:error, changeset} = PasswordReset.complete("valid_token", "invalid")

       refute changeset.valid?
    end

    test "clears out the token", %{user: %{id: id}} do
      PasswordReset.complete("valid_token", "new password")

      user = Repo.get(User, id)

      refute user.reset_token
    end

    test "responds with ok" do
      assert :ok == PasswordReset.complete("valid_token", "new password")
    end
  end

  def clear_reset_cache do
    set_cache_state %{}
  end

  def set_cache_state(state) do
    :sys.replace_state(PasswordResetHoard, fn(_) -> state end)
  end

  def sync_hoard do
    :sys.get_state(PasswordResetHoard)
  end
end

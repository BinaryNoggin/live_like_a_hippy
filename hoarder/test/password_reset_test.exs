defmodule Hoarder.PasswordResetTest do
  use Hoarder.TestCase, async: true
  alias Hoarder.PasswordReset
  alias Hoarder.User

  describe "starting with an email that doesn't exist" do
    test "has default secure response" do
      assert standard_response(PasswordReset.start("fake@example.com"))
    end
  end

  describe "starting with an email that is in the system" do
    setup do
      email = "real@example.com"

      user = Repo.insert!(User.enroll_changeset(%User{}, %{email: email, plain_password: "password"}))
      response = PasswordReset.start(email)

      %{user: user, response: response}
    end

    test "has default secure response", %{response: response} do
      assert standard_response(response)
    end

    test "the user is assigned a reset tokoen", %{user: %{id: id}} do
      user = Repo.get(User, id)

      assert user.reset_token
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
      |> User.reset_request_changeset
      |> Repo.update!

      %{user: user}
    end

    test "changes the password and valid password", %{user: %{password: original_password, reset_token: reset_token, id: id}} do
      PasswordReset.complete(reset_token, "new password")

      user = Repo.get(User, id)

      refute original_password == user.password
    end

    test "does not change the password with an invalid password", %{user: %{password: original_password, reset_token: reset_token, id: id}} do
      PasswordReset.complete(reset_token, "invalid")

      user = Repo.get(User, id)

      assert original_password == user.password
    end

    test "returns invalid changeset", %{user: %{reset_token: reset_token}} do
       {:error, changeset} = PasswordReset.complete(reset_token, "invalid")

       refute changeset.valid?
    end

    test "clears out the token", %{user: %{reset_token: reset_token, id: id}} do
      PasswordReset.complete(reset_token, "new password")

      user = Repo.get(User, id)

      refute user.reset_token
    end

    test "responds with ok", %{user: %{reset_token: reset_token}} do
      assert :ok == PasswordReset.complete(reset_token, "new password")
    end
  end

  def standard_response(response) do
    response == :ok
  end
end

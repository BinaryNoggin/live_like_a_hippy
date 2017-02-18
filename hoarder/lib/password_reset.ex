defmodule Hoarder.PasswordReset do
  alias Hoarder.Repo
  alias Hoarder.User
  @type email :: String.t()
  @type token :: String.t()
  @type password :: String.t()

  @spec start(email) :: :ok
  def start(email) do
    PasswordResetHoard.add(email)
    :ok
  end

  @spec complete(token, password) :: :ok | :error | {:error, map}
  def complete(token, new_password) do
    case update_password(token, new_password) do
      {:ok, _} -> :ok
      otherwise -> otherwise
    end
  end

  defp update_password(token, new_password) do
    case PasswordResetHoard.get_user(token) do
      :error -> :error
      {:ok, user} ->
        user
        |> User.enroll_changeset(%{plain_password: new_password})
        |> Repo.update
    end
  end
end

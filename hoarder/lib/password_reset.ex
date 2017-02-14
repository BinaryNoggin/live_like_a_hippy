defmodule Hoarder.PasswordReset do
  alias Hoarder.Repo
  alias Hoarder.User

  @spec start(String.t()) :: String.t()
  def start(email) do
    if user = Repo.get_by(User, email: email) do
      user
      |> User.reset_request_changeset
      |> Repo.update!
    end

    :ok
  end

  @spec complete(String.t(), String.t()) :: term
  def complete(token, new_password) do
    case update_password(token, new_password) do
      {:ok, _} -> :ok
      otherwise -> otherwise
    end
  end

  defp update_password(token, new_password) do
    case Repo.get_by(User, reset_token: token) do
      nil -> :error
      user ->
        user
        |> User.enroll_changeset(%{plain_password: new_password})
        |> Repo.update
    end
  end
end

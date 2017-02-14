defmodule Hoarder.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string
    field :reset_token, :string
    field :plain_password, :string, virtual: true
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w{email plain_password})
    |> unique_constraint(:email)
  end

  def enroll_changeset(model, params \\ %{}) do
    model
    |> changeset(params)
    |> validate_length(:plain_password, min: 8)
    |> validate_required([:plain_password, :email])
    |> secure_password
  end

  def secure_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{plain_password: pass}} ->
        changeset
        |> put_change(:password, Comeonin.Bcrypt.hashpwsalt(pass))
        |> put_change(:reset_token, nil)
      _ -> changeset
    end
  end
end

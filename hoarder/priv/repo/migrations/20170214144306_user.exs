defmodule Hoarder.Repo.Migrations.User do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password, :string
      add :email, :string
      add :reset_token, :string
    end
    create unique_index :users, [:email]
  end
end

defmodule PasswordResetHoard do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add(token, user) do
    Agent.cast(__MODULE__, &Map.put(&1, token, user))
  end

  def get_user(token) do
    Agent.get(__MODULE__, &Map.fetch(&1, token))
  end

  def remove(token) do
    Agent.cast(__MODULE__, &Map.delete(&1, token))
  end
end

defmodule PasswordResetHoard.FailoverStorage do

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def dump(state) do
    Agent.cast(__MODULE__, fn(_) -> state end)
  end

  def load do
    Agent.get(__MODULE__, fn(state) -> state end)
  end
end

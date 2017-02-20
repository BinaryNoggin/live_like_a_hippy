defmodule PasswordResetHoard.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(PasswordResetHoard.FailoverStorage, []),
      worker(PasswordResetHoard, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end

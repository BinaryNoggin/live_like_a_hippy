defmodule PasswordResetHoard do
  use GenServer
  alias Hoarder.Repo
  alias Hoarder.User

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(email) do
    GenServer.cast(__MODULE__, {:add, email})
  end

  def remove(token) do
    GenServer.cast(__MODULE__, {:remove, token})
  end

  def get_user(token) do
    GenServer.call(__MODULE__, {:get_user, token})
  end

  def handle_cast({:add, email}, state) do
    {:noreply,
      if user = Repo.get_by(User, email: email) do
        Map.put(state, Ecto.UUID.generate, user)
      else
        state
      end
    }
  end

  def handle_cast({:remove, token}, state) do
    {:noreply, Map.delete(state, token)}
  end

  def handle_call({:get_user, token}, _from, state) do
    {:reply, Map.fetch(state, token), state}
  end
end

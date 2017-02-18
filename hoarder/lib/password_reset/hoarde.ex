defmodule PasswordResetHoard do
  use GenServer
  alias Hoarder.Repo
  alias Hoarder.User
  alias PasswordResetHoard.FailoverStorage

  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok,FailoverStorage.load}
  end

  def add(email, name \\ @name) do
    GenServer.cast(name, {:add, email})
  end

  def remove(token, name \\ @name) do
    GenServer.cast(name, {:remove, token})
  end

  def get_user(token, name \\ @name) do
    GenServer.call(name, {:get_user, token})
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

  def terminate(_reason, state) do
    FailoverStorage.dump(state)
  end
end

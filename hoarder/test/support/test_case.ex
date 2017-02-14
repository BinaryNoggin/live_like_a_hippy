defmodule Hoarder.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Hoarder.Repo

      import Hoarder.TestCase
      import Ecto
      import Ecto.Changeset
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Hoarder.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Hoarder.Repo, {:shared, self()})
    end
    :ok
  end
end

defmodule PasswordResetHoardFailoverTest do
  use Hoarder.TestCase, async: false

  test "loads state after a crash" do
    :sys.replace_state(PasswordResetHoard, fn(_) -> :loaded end)

    assert :loaded == :sys.get_state(PasswordResetHoard)

    GenServer.stop(PasswordResetHoard)
    Process.sleep(500)

    assert  :loaded == :sys.get_state(PasswordResetHoard)
  end
end

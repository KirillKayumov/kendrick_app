defmodule Kendrick.Mocks.DateTimeBehaviour do
  @callback utc_now() :: DateTime.t()
end

Mox.defmock(Kendrick.date_time(), for: Kendrick.Mocks.DateTimeBehaviour)

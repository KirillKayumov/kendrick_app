defmodule Kendrick.Mocks.DateTimeBehaviour do
  @callback utc_now() :: DateTime.t()
  @callback truncate(DateTime.t(), :second) :: DateTime.t()
end

Mox.defmock(Kendrick.date_time(), for: Kendrick.Mocks.DateTimeBehaviour)

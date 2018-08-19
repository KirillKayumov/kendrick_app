defmodule ESpec.Phoenix.Extend do
  def model do
    quote do
      alias Kendrick.Repo
    end
  end

  def controller do
    quote do
      alias Kendrick
      import Kendrick.Router.Helpers

      @endpoint Kendrick.Endpoint
    end
  end

  def view do
    quote do
      import Kendrick.Router.Helpers
    end
  end

  def channel do
    quote do
      alias Kendrick.Repo

      @endpoint Kendrick.Endpoint
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

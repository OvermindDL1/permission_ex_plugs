defmodule PermissionEx.Plugs.TestPermissions do
  @moduledoc """
  This calls `test_conn_permissions/1` on the module that is passed in to the
  options of this plug as `:callback_module`.

  If the `test_conn_permissions/1` callback returns anything but true then this
  plug will call `test_conn_permissions_failed/1` with the `conn` on the
  `:callback_module`.
  """

  defmodule OptionsError do
    @moduledoc "Error raised when something fails with the options"

    message =
      "Unknown error happened with an option settings"

    defexception message: message, plug_status: 401
  end

  #import Plug.Conn

  @behaviour Plug


  def init(options) do
    case Keyword.get(options, :callback_module, nil) do
      nil -> raise OptionsError, message: "Callback module is not defined", plug_status: 500
      callback_module -> callback_module
    end
  end


  def call(conn, callback_module) do
    case try_callback(conn, callback_module) do
      true -> conn
      false -> callback_failed(conn, callback_module)
    end
  end


  defp try_callback(conn, callback_module) do
    callback_module.test_conn_permissions(conn)
  end

  defp callback_failed(conn, callback_module) do
    callback_module.test_conn_permissions_failed(conn)
  end
end

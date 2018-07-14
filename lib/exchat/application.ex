defmodule Exchat.Application do
  use Application
  alias Exchat.{Server}

  def start(_type, _args) do
    Server.init_store_table()

    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))

    children = [
      {Exchat.Broadcast, name: Exchat.Broadcast},
      {Task.Supervisor, name: Exchat.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Server.accept(port) end}, restart: :permanent)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Exchat.Supervisor)
  end
end

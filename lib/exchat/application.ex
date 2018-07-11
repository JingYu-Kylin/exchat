defmodule Exchat.Application do
  use Application

  def start(_type, _args) do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))

    children = [
      {Task.Supervisor, name: Exchat.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Exchat.Server.accept(port) end}, restart: :permanent)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Exchat.Supervisor)
  end
end

defmodule Exchat.Supervisor do
  use Supervisor
  alias Exchat.{Server}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))

    children = [
      {Exchat.Broadcast, name: Exchat.Broadcast},
      {Task.Supervisor, name: Exchat.TaskSupervisor},
      {Exchat.Server, name: Exchat.Server, port: 1056},
      Supervisor.child_spec(Exchat.Event, [])
    ]

    Supervisor.init(children, strategy: :one_for_one, name: Exchat.Supervisor)
  end
end

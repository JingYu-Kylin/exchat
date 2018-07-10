defmodule Exchat.Application do
  use Application

  def start(_type, args) do
    args = Keyword.merge(args, name: Exchat.Server)
    server = {Exchat.Server, args}
    children = [server]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
defmodule Exchat.Broadcast do
  @moduledoc """
    广播消息内容
  """

  use GenServer

  alias Exchat.{Server, Message}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:response_all, msg, cpid}, state) do
    Server.get_clients()
    |> Enum.each(fn [pid, socket] ->
      if pid != cpid,
        do:
          Server.write_line(
            Message.gen_msg_header(Server.gen_nickname_by_pid(cpid)) <> msg,
            socket
          )
    end)

    {:noreply, state}
  end

  def response_all(msg, pid) do
    GenServer.cast(__MODULE__, {:response_all, msg, pid})
  end
end

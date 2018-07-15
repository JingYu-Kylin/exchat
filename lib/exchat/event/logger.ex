defmodule Exchat.Event.Logger do
  @behaviour :gen_event
  alias Exchat.{Event}

  def init(state) do
    {:ok, state}
  end

  def handle_info(_info, state) do
    {:ok, state}
  end

  def terminate(_reson, _state) do
    :ok
  end

  def handle_call(_request, state) do
    reply = :ok
    {:ok, reply, state}
  end

  def add_handler do
    write_line = fn line ->
      File.write("event.log", line <> "\n", [:append])
    end

    Event.add_handler(__MODULE__, write_line: write_line)
  end

  def handle_event({:connected, nickname}, [write_line: write_line] = state) do
    write_line.("#{nickname} 已连接。")
    {:ok, state}
  end
end

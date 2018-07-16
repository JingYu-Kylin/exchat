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
    write = fn line ->
      File.write("event.log", line, [:append])
    end

    Event.add_handler(__MODULE__, %{write: write})
  end

  def handle_event({:connected, nickname}, %{write: write} = state) do
    write.(gen_line("#{nickname} 加入聊天室\n"))
    {:ok, state}
  end

  def handle_event({:receive, nickname, msg}, %{write: write} = state) do
    write.(gen_line("#{nickname} 说：#{msg}"))
    {:ok, state}
  end

  def handle_event({:closed, nickname}, %{write: write} = state) do
    write.(gen_line("#{nickname} 离开聊天室\n"))
    {:ok, state}
  end

  defp time_header(line) do
    d = DateTime.utc_now()
    "[#{d.year}-#{d.month}-#{d.day} #{d.hour}:#{d.minute}:#{d.second}]\t" <> line
  end

  defp gen_line(line) do
    time_header(line)
  end
end

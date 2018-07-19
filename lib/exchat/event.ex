defmodule Exchat.Event do
  @moduledoc """
    事件管理器以及具体的事件触发函数
  """
  def start_link do
    :gen_event.start_link({:local, __MODULE__})
  end

  def add_handler(handler, args) do
    :gen_event.add_handler(__MODULE__, handler, args)
  end

  def delete_handler(handler, args) do
    :gen_event.delete_handler(__MODULE__, handler, args)
  end

  @doc """
  记录新的客户端连接
  """
  def connected(nickname) do
    :gen_event.notify(__MODULE__, {:connected, nickname})
  end

  @doc """
  记录新的接收到的消息
  """
  def receive_msg(nickname, msg) do
    :gen_event.notify(__MODULE__, {:receive, nickname, msg})
  end

  @doc """
  记录客户端关闭事件
  """
  def closed(nickname) do
    :gen_event.notify(__MODULE__, {:closed, nickname})
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent
    }
  end
end

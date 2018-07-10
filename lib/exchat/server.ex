defmodule Exchat.Server do
  use GenServer

  @default_port 1055
  defstruct [:port, :lsock, connecting_count: 0]

  def start_link(opts) do
    port = Keyword.get(opts, :port, @default_port)
    GenServer.start_link(__MODULE__, port, opts)
  end

  @doc """
  获取连接数
  """
  def get_connecting_count do
    GenServer.call(__MODULE__, :get_connecting_count)
  end

  @doc """
  停止进程
  """
  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  def init(port) do
    {:ok, lsock} = :gen_tcp.listen(port, [active: true])
    {:ok, %__MODULE__{port: port, lsock: lsock}, 0}
  end

  @doc """
  处理 TCP 数据
  """
  def handle_info({:tcp, socket, raw_data}, state) do
    :gen_tcp.send(socket, "#{IO.ANSI.color(64)}Received: #{IO.ANSI.default_color()}#{raw_data}")
    {:noreply, state}
  end

  @doc """
  处理超时（接受连接）
  """
  def handle_info(:timeout, %{lsock: lsock} = state) do
    {:ok, _sock} = :gen_tcp.accept(lsock)
    {:noreply, state}
  end

  @doc """
  连接关闭
  """
  def handle_info({:tcp_closed, _port}, state) do
    {:stop, :normal, state}
  end

  @doc """
  返回连接数
  """
  def handle_call(:get_connecting_count, _from, state) do
    {:reply, {:ok, state.connecting_count}, state}
  end

  @doc """
  关闭 GenServer
  """
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end


  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end
end

defmodule Exchat.Server do
  alias Exchat.{Message, Broadcast, Event}

  @clients_table :client_socket

  @doc """
  初始化 PID/Socket 表
  """
  def init_store_table do
    :ets.new(@clients_table, [:named_table, :public])
  end

  # 添加一个客户端连接
  defp add_client(pid, socket) do
    :ets.insert(@clients_table, {pid, socket})
  end

  # 移除一个客户端连接
  defp remove_client(pid) do
    :ets.delete(@clients_table, pid)
  end

  @doc """
  获取全部客户端连接
  """
  def get_clients do
    :ets.match(:client_socket, {:"$1", :"$2"})
  end

  @doc """
  监听端口并等待 TCP 连接
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  @doc """
  监听端口并等待 TCP 连接
  """
  def loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # 启动新进程处理数据
    {:ok, pid} = Task.Supervisor.start_child(Exchat.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    # 添加进客户端列表
    add_client(pid, client)
    Event.connected(gen_nickname_by_pid(pid))
    # 发送欢迎消息
    welcome(pid, client)
    loop_acceptor(socket)
  end

  @doc """
  反馈并广播欢迎消息
  """
  def welcome(pid, socket) do
    nickname = gen_nickname_by_pid(pid)
    # 发送欢迎消息
    Message.gen_welcome_msg(nickname)
    |> write_line(socket)

    # 广播新用户加入消息
    Message.gen_welcome_msg_for_new_user(nickname)
    |> Broadcast.response_all(pid)
  end

  @doc """
  读取并响应消息
  """
  def serve(socket) do
    line = read_line(socket)
    Event.receive_msg(gen_nickname_by_pid(self()), line)
    write_ok(socket)
    Broadcast.response_all(line, self())
    serve(socket)
  end

  @doc """
  读取一行消息
  """
  def read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data

      {:error, :closed} ->
        handle_closed()
    end
  end

  @doc """
  处理连接关闭
  """
  def handle_closed do
    Event.closed(gen_nickname_by_pid(self()))
    remove_client(self())

    Message.gen_leaves_msg(gen_nickname_by_pid(self()))
    |> Broadcast.response_all(self())

    Process.exit(self(), :kill)
  end

  @doc """
  写入一行消息
  """
  def write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  @doc """
  响应 ok
  """
  def write_ok(socket) do
    write_line(
      Message.gen_response_ok(),
      socket
    )
  end

  @doc """
  通过 pid 生成昵称
  """
  def gen_nickname_by_pid(pid) do
    "#{:erlang.pid_to_list(pid) |> List.to_string()}"
  end
end

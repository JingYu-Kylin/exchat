defmodule Exchat.Server do
  alias Exchat.{Message}

  @clients_table :client_socket

  # 初始化 PID/Socket 表
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
  监听端口并等待 TCP 连接
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    loop_acceptor(socket)
  end

  # 监听端口并等待 TCP 连接
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # 启动新进程处理数据
    {:ok, pid} = Task.Supervisor.start_child(Exchat.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    # 添加进客户端列表
    add_client(pid, client)
    Message.print_on_accept()
    # 发送欢迎消息
    welcome(pid, client)
    loop_acceptor(socket)
  end

  defp welcome(pid, socket) do
    nickname = gen_nickname_by_pid(pid)
    # 发送欢迎消息
    Message.gen_welcome_msg(nickname)
    |> write_line(socket)

    # 广播新用户加入消息
    Message.gen_welcome_msg_for_new_user(nickname)
    |> response_all(pid)
  end

  # 读取并响应消息
  defp serve(socket) do
    line = read_line(socket)
    Message.print_on_receive(line)
    write_ok(socket)
    response_all(line, self())
    serve(socket)
  end

  # 将消息广播全部所连接的客户端
  defp response_all(msg, cpid) do
    :ets.match(:client_socket, {:"$1", :"$2"})
    |> Enum.each(fn [pid, socket] ->
      if pid != cpid,
        do: write_line(Message.gen_msg_header(gen_nickname_by_pid(cpid)) <> msg, socket)
    end)
  end

  # 读取一行消息
  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data

      {:error, :closed} ->
        Message.print_on_closed()
        remove_client(self())

        Message.gen_leaves_msg(gen_nickname_by_pid(self()))
        |> response_all(self())

        Process.exit(self(), :kill)
    end
  end

  # 写入一行消息
  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  # 响应 ok
  defp write_ok(socket) do
    write_line(
      Message.gen_response_ok(),
      socket
    )
  end

  # 通过 pid 生成昵称
  defp gen_nickname_by_pid(pid) do
    "#{:erlang.pid_to_list(pid) |> List.to_string()}"
  end
end

defmodule Exchat.Server do
  import Exchat.Message

  @doc """
  监听端口并等待 TCP 连接
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Exchat.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    print_on_accept()
    loop_acceptor(socket)
  end

  defp serve(socket) do
    line = read_line(socket)
    print_on_receive(line)
    write_ok(socket)

    serve(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
      {:error, :closed} ->
        print_on_closed()
        Process.exit(self(), :kill)
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  defp write_ok(socket) do
    write_line(
      gen_response_ok(),
      socket
    )
  end
end

defmodule Exchat.Application do
  use Application
  alias Exchat.{Server, Supervisor}

  def start(_type, _args) do
    # 初始化存储表
    Server.init_store_table()
    # 启动监控树
    case Supervisor.start_link([]) do
      {:ok, pid} ->
        # 添加事件处理器（日志）
        Exchat.Event.Logger.add_handler()
        {:ok, pid}

      error ->
        {:error, error}
    end
  end
end

defmodule Exchat.Message do
  @moduledoc """
    生成规范的响应消息内容
  """

  def gen_response_ok do
    "#{IO.ANSI.color(75)}SEND: #{IO.ANSI.color(76)}OK#{IO.ANSI.default_color()}\n"
  end

  def gen_msg_header(nickname) do
    d = DateTime.utc_now()

    "#{IO.ANSI.color(12)}[#{IO.ANSI.color(13)}#{nickname}#{IO.ANSI.color(12)}]\t#{
      IO.ANSI.color(82)
    }#{d.year}-#{d.month}-#{d.day} #{d.hour}:#{d.minute}:#{d.second}#{IO.ANSI.default_color()}\t"
  end

  def gen_welcome_msg(nickname) do
    "#{IO.ANSI.color(11)}Hello #{IO.ANSI.color(14)}#{nickname}#{IO.ANSI.color(11)}, welcome to the chat room.#{
      IO.ANSI.default_color()
    }\n"
  end

  def gen_welcome_msg_for_new_user(nickname) do
    "#{IO.ANSI.color(11)}User #{IO.ANSI.color(14)}#{nickname}#{IO.ANSI.color(11)} joined the chat room.#{
      IO.ANSI.default_color()
    }\n"
  end

  def gen_leaves_msg(nickname) do
    "#{IO.ANSI.color(11)}User #{IO.ANSI.color(14)}#{nickname}#{IO.ANSI.color(63)} leaves the chat room.#{
      IO.ANSI.default_color()
    }\n"
  end
end

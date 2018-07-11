defmodule Exchat.Message do
  def print_on_receive(msg) do
    "#{IO.ANSI.color(75)}RECEIVED: #{IO.ANSI.default_color()}#{String.trim(msg)}"
    |> IO.puts()
  end

  def print_on_closed() do
    "#{IO.ANSI.color(75)}DISCONNET: #{IO.ANSI.default_color()}Closed."
    |> IO.puts()
  end

  def print_on_accept() do
    "#{IO.ANSI.color(75)}CONNECTED: #{IO.ANSI.default_color()}Keep."
    |> IO.puts()
  end

  def gen_response_ok do
    "#{IO.ANSI.color(75)}RESPONSE: #{IO.ANSI.color(76)}OK#{IO.ANSI.default_color()}\n"
  end
end

# Exchat

A chat room server, implemented using the Elixir language.

## Description

This is a simple OTP demo application that includes a use case for GenServer/:gen_event/Task/Task.Supervisor/:gen_tcp/:ets and Supervision Tree, using Distillery Dockerized.

## Running

Server:

````
docker run -ti --name exchat -p 8055:1055 -d bluerain/exchat
````

Client:

````
telnet localhost 8055
````

## Demonstration

![](https://github.com/Hentioe/exchat/raw/master/.github/exchat-0.gif)

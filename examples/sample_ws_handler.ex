defmodule SampleWsHandler do
  @behaviour :websocket_client

  def start_link do
    :websocket_client.start_link("wss://echo.websocket.org", __MODULE__, [])
  end

  def init([]) do
    {:once, 2}
  end

  def onconnect(_, state) do
    :websocket_client.cast(self(), {:text, "message 1"})
    {:ok, state}
  end

  def ondisconnect({:remote, :closed}, state) do
    {:reconnect, state}
  end

  def websocket_handle({:pong, _}, _, state) do
    {:ok, state}
  end

  def websocket_handle({:text, msg}, _ConnState, 5) do
    IO.puts("Received msg #{msg}. I is done!")
    {:close, "", "done"}
  end

  def websocket_handle({:text, msg}, _ConnState, state) do
    IO.puts("Received msg #{msg}")
    :timer.sleep(1000)
    {:reply, {:text, "hello, this is message ##{state}"}, state+1}
  end

	def websocket_info(:start, _, state) do
    {:reply, {:text, "erlang message received"}, state}
	end

	def websocket_terminate(reason, _, state) do
    IO.puts("Websocket closed in state #{state} with reason #{reason}")
    :ok
	end

end


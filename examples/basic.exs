defmodule Examples.ObsWebSocket do
  use ObsWebSocket

  def start_link(url, state \\ nil) do
    WebSockex.start_link(url, __MODULE__, state)
  end

  @impl true
  def handle_frame({type, message}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(message)}")
    {:ok, state}
  end
end

{:ok, _conn} = Examples.ObsWebSocket.start_link("ws://localhost:4455")
Process.sleep(1_000)

defmodule Examples.ObsWebSocket do
  use ObsWebSocket

  def start_link(url, state) do
    WebSockex.start_link(url, __MODULE__, state)
  end

  def password(state) do
    state[:password]
  end

  @impl true
  def handle_frame({type, message}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(message)}")
    {:ok, state}
  end

  @impl true
  def handle_info({:request, type, data}, state) do
    handle_request(type, data, state)
  end
end

{:ok, conn} = Examples.ObsWebSocket.start_link("ws://localhost:4455", password: "password")

# Wait for the connection to be identified
Process.sleep(1_000)

conn |> ObsWebSocket.request(:SetInputSettings, %{
  inputName: "message",
  inputSettings: %{text: "Hello OBS!"}
})

Process.sleep(1_000)

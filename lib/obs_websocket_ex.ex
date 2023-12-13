defmodule ObsWebSocket do
  def request(client, type, data) do
    send(client, {:request, type, data})
  end

  defmacro __using__(opts) do
    quote location: :keep do
      use WebSockex, unquote(opts)
      require Logger

      @doc false
      def password(:dummy), do: ""

      @doc false
      def handle_frame({type, message}, state) when is_binary(message) do
        decoded_message = message |> Jason.decode!()
        handle_frame({type, decoded_message}, state)
      end

      def handle_frame({:text, message = %{"op" => 0, "d" => data}}, state) do
        handle_hello(data, state)
      end

      defp handle_hello(%{"authentication" => authentication} = data, state) do
        Logger.debug("Hello (authentication required): #{inspect(data)}")

        %{
          "challenge" => challenge,
          "salt" => salt
        } = authentication

        # https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#creating-an-authentication-string
        authentication_string =
          "#{password(state)}#{salt}"
          |> then(fn s -> :crypto.hash(:sha256, s) end)
          |> Base.encode64()
          |> Kernel.<>(challenge)
          |> then(fn s -> :crypto.hash(:sha256, s) end)
          |> Base.encode64()

        handle_reply(
          1,
          %{
            rpcVersion: data["rpcVersion"],
            authentication: authentication_string
          },
          state
        )
      end

      defp handle_hello(%{} = data, state) do
        Logger.debug("Hello (authentication not required): #{inspect(data)}")
        handle_reply(1, %{rpcVersion: data["rpcVersion"]}, state)
      end

      defp handle_request(request_type, request_data, state) do
        data =
          %{
            "requestType" => request_type,
            "requestId" => UUID.uuid1(),
            "requestData" => request_data
          }

        handle_reply(6, data, state)
      end

      defp handle_reply(op, data, state) do
        encoded_data = %{"op" => op, "d" => data} |> Jason.encode!()
        {:reply, {:text, encoded_data}, state}
      end
    end
  end
end

defmodule ObsWebsocketEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :obs_websocket_ex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.4"}
    ]
  end
end

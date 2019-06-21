defmodule Mit.MixProject do
  use Mix.Project

  def project do
    [
      app: :mit,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
			deps: deps(),
			escript: escript(),
    ]
  end

  def escript do
    [
      main_module: Mit.CLI
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:ex_cli, "~> 0.1.6"}
    ]
  end
end

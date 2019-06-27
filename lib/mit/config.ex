defmodule Mit.Config do
	def save_to_local_env(key, value) do
		{result, _} = System.cmd("git", ["config", "--local", "--add", key, value])
		result |> String.trim
	end

	def read_from_local_env(key) do
		{result, _} = System.cmd("git", ["config", "--local", "--get", key])
		result |> String.trim
	end

	def clear_key_from_local_env(key) do
		{result, _} = System.cmd("git", ["config", "--local", "--unset", key])
		result |> String.trim
	end
end

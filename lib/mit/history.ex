defmodule Mit.History do
	defmodule Filter do
		defstruct user: nil, start_date: nil, end_date: nil
	end

	defmodule Report do
		defstruct by_type: nil, by_test_vs_code: nil
	end

	def get_files_changed, do: get_files_changed(%{})
	def get_files_changed(params) do
		options = [ "--no-pager", "log", "--name-only"]

		options = if Map.has_key? params, :author do
			options ++ ["--author=#{params.author}"]
		else
			options
		end

		options = if Map.has_key? params, :since do
			 options ++ ["--since=#{params.since}"]
		else
			options
		end

		options = if Map.has_key? params, :until do
			options ++ ["--until=#{params.until}", ]
		else
			options
		end

		options = options ++ ["--pretty=format:"]

		execute(options)
		|> String.split("\n")
		|> Enum.filter(fn path -> path != "" end)
		|> Enum.uniq()
		|> Enum.sort()


	end

	defp execute(options) do
		case System.cmd("git", options, stderr_to_stdout: true) do
			{error, x} when x != 0 -> error
			{result, _} -> result
		end
	end
end

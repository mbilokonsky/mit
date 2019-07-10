defmodule Mit.History do
	def changed_files_diff, do: changed_files_diff("master")
	def changed_files_diff(target_reference) do
		options = [ "--no-pager", "diff", "--name-only", target_reference]

		execute(options)
		|> String.split("\n")
		|> Enum.filter(fn path -> path != "" end)
		|> Enum.sort()
	end

	def changed_files_repo, do: changed_files_repo(%{})
	def changed_files_repo(params) do
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

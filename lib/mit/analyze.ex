defmodule Mit.Analyze do
	def analyze_repo, do: analyze_repo(%{})
	def analyze_repo(params) do
		files = Mit.History.get_files_changed(params)
		total_files_changed = Enum.count(files)

		test_changes = files |> Enum.filter(fn filename -> is_test? filename end)
		test_files_changed = Enum.count(test_changes)

		types = Enum.map(files, fn file -> get_type(file)end)
		files_by_type = Enum.reduce(types, %{}, fn val, acc ->
			if Map.has_key?(acc, val) do
				Map.replace!(acc, val, acc[val] + 1)
			else
				Map.put(acc, val, 1)
			end
		end)

		%{
			total_files_changed: total_files_changed,
			test_files_changed: test_files_changed,
			by_type: files_by_type
		}
	end

	def get_file_type(path) do
		filename = path
		|> String.split("/")
		|> Enum.reverse
		|> Enum.at(0)

		get_type filename
	end

	def is_test?(path) do
		output = false
		output = if String.contains?(path, "test") do
			true
		else
			output
		end

		output = if String.contains?(path, "spec") do
			true
		else
			output
		end

		# what else?

		output
	end

	defp get_type(filename) do
		case String.split(filename, ".") |> Enum.reverse do
			[extension, _|_] -> String.to_atom extension
			[name] when filename == name -> :unknown_type
			_ -> :unknown
		end
	end
end

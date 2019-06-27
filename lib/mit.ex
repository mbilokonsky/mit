defmodule Mit do

	def open_url({:error, errors}) do
		IO.puts IO.ANSI.light_red_background <> "Unable to open jira url because of the following errors:" <> IO.ANSI.default_background
		IO.puts "\t" <> Enum.join(errors, "\n\t")
	end
	def open_url(url) do
		System.cmd("open", [url])
	end

	def open_jira() do open_url Mit.Jira.get_jira_url() end

	def open_github(), do: open_github("origin")
	def open_github(remote_name), do: open_github(remote_name, get_branch())
	def open_github(nil, nil), do: open_github()
	def open_github(nil, branch), do: open_github("origin", branch)
	def open_github(remote_name, nil), do: open_github(remote_name)
	def open_github(remote_name, branch) do open_url get_github_url(remote_name, branch) end

	def open_pulls(), do: open_pulls("upstream")
	def open_pulls(nil), do: open_pulls()
	def open_pulls(remote_name) do open_url get_github_pulls_url(remote_name)	end

  def get_branch() do
		{result, _exit_code} = System.cmd("git", ["status"])

		result
    |> String.split("\n")
		|> Enum.take(1)
		|> Enum.map(fn line ->
			[_, branch] = String.split(line, " branch ")
			branch
		end)
		|> Enum.join("")
		|> String.trim
	end

	def get_account_and_repo(remote_name) do
		{result, _} = System.cmd("git", ["remote", "get-url", remote_name])
		result |> sanitize_remote
	end

	defp get_github_url(remote_name, branch) do
		url = get_account_and_repo(remote_name) |> build_github_url
		case branch do
			nil -> :error
			"master" -> url
			branch -> url <> "/tree/" <> branch
		end
	end

	defp get_github_pulls_url(remote_name) do
		get_account_and_repo(remote_name) <> "/pulls"
	end

	def sanitize_remote("www.github.com/" <> string) do "https://github.com/" <> string end
	def sanitize_remote("github.com/" <> string) do "https://github.com/" <> string end
	def sanitize_remote("http://" <> string) do "https://" <> string end
	def sanitize_remote("https://" <> string) do "https://" <> string end
	def sanitize_remote("ssh://" <> string), do: sanitize_remote(string)
	def sanitize_remote("git@github.com/" <> path), do: sanitize_remote(path)
	def sanitize_remote("git@github.com:" <> path), do: sanitize_remote(path)
	def sanitize_remote(path) do
		[account_name, repo_name] = String.split(path, "/")
		[account_name, repo_name]
	end

	def build_github_url([account_name, repo_name]) do
		"https://github.com/#{account_name}/#{repo_name}" |> String.trim
	end


end

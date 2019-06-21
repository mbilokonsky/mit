defmodule Mit do
	def open_url(url) do System.cmd("open", [url]) end

	def open_jira() do open_url get_jira_url() end

	def open_github(), do: open_github("origin")
	def open_github(remote_name), do: open_github(remote_name, get_branch())
	def open_github(nil, nil), do: open_github()
	def open_github(nil, branch), do: open_github("origin", branch)
	def open_github(remote_name, nil), do: open_github(remote_name)
	def open_github(remote_name, branch) do
		IO.puts("Opening github")
		IO.puts("\tremote_name: #{remote_name}")
		IO.puts("\tbranch: #{branch}")
		open_url get_github_url(remote_name, branch)
	end

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

	def get_url(remote_name) do
		{result, _} = System.cmd("git", ["remote", "get-url", remote_name])
		result
	end

	defp get_jira_url() do
		ticket = get_branch()
		team_name = System.get_env("JIRA_TEAM")
		case team_name do
			nil -> "Please set your jira team name in the environment variable JIRA_TEAM"
			str -> "https://#{str}.atlassian.net/browse/#{ticket}"
		end
	end

	defp get_github_url(remote_name, branch) do
		url = get_url(remote_name) |> sanitize_origin
		case branch do
			nil -> :error
			"master" -> url
			branch -> url <> "/tree/" <> branch
		end
	end

	defp sanitize_origin("www.github.com/" <> string) do "https://github.com/" <> string end
	defp sanitize_origin("github.com/" <> string) do "https://github.com/" <> string end
	defp sanitize_origin("http://" <> string) do "https://" <> string end
	defp sanitize_origin("https://" <> string) do "https://" <> string end
	defp sanitize_origin("ssh://" <> string), do: sanitize_origin(string)
	defp sanitize_origin("git@github.com/" <> path), do: sanitize_origin(path)
	defp sanitize_origin("git@github.com:" <> path), do: sanitize_origin(path)
	defp sanitize_origin(path) do
		[account_name, repo_name] = String.split(path, "/")
		"https://github.com/#{account_name}/#{repo_name}" |> String.trim
	end
end

defmodule Mit.PR do
	defstruct [:title, :body, :source_branch, source_remote: "origin", target_remote: "upstream", target_branch: "master"]

	def create_new_pr(options) do
		Mit.open_url create(options) |> build_url
	end

	def create(options) do
		%Mit.PR{
			title: (options[:title] || "") |> String.trim,
			body: (options[:body] || "") |> String.trim,
			source_branch: (options[:source_branch] || Mit.get_branch())  |> String.trim,
			source_remote: options[:source_remote] |> String.trim,
			target_remote: options[:target_remote] |> String.trim,
			target_branch: options[:target_branch] |> String.trim
		}
	end

	def build_url(pr) do
		[target_account, target_repo_name] = get_repo_data(pr.target_remote)
		[source_account | _] = get_repo_data(pr.source_remote)

		url_base = build_url_base(target_account, target_repo_name)
		target_reference = pr.target_branch
		source_reference = if (target_account == source_account) do
			"#{pr.source_branch}"
		else
			"#{source_account}:#{pr.source_branch}"
		end

		query_string = build_query(pr)
		url_base <> "/compare/#{target_reference}...#{source_reference}" <> query_string
	end

	def build_query(pr) do
		q = "?quick_pull=1"
		q = if pr.body do
			q <> "&body=#{pr.body}"
		else
			q
		end

		q = if pr.title do
			q <> "&title=#{pr.title}"
		else
			q
		end

		q
	end

	defp get_repo_data(remote_name) do
		Mit.get_account_and_repo(remote_name)
	end

	defp build_url_base(account_name, repo_name) do
		Mit.build_github_url([account_name, repo_name])
	end

end

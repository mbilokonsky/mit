defmodule Mit.Jira do
	@jira_key "mit.jira-url"
	@ticket_placeholder "@ticket@"

	def get_jira_url() do
		saved_url = get_saved_jira_url()
		suggested_url = get_suggested_jira_url()

		case {saved_url, suggested_url} do
			{ "http" <> rest, _ } -> "http" <> rest
			{ "", "http" <> rest } -> use_jira_suggestion?("http" <> rest)
			_ -> require_jira_url()
		end
	end

	def clear_jira_url() do
		Mit.Config.clear_key_from_local_env(@jira_key <> "." <> Mit.get_branch())
	end

	defp require_jira_url() do
		jira_url = IO.gets "Enter JIRA ticket URL here: "
		confirm_jira_url(jira_url)
	end

	defp use_jira_suggestion?(url) do
		url = String.replace(url, @ticket_placeholder, Mit.get_branch())
		formatted_url = format_template(url)
		input = IO.gets "Do you want to use this URL as the JIRA ticket url for this branch of this repository?\n#{formatted_url} y/n: "
		answer = input |> String.capitalize |> String.trim |> String.first

		case answer do
			"" -> require_jira_url()
			"N" -> require_jira_url()
			"Y" -> confirm_jira_url(url)
			_ -> use_jira_suggestion?(url)
		end
		url
	end

	def confirm_jira_url(url) do
		errors = validate_jira_url(url)

		case errors do
			[] -> Mit.Config.save_to_local_env(construct_branch_jira_key(), url)
			[_h|_] -> {:error, errors}
		end
	end

	defp construct_branch_jira_key do
		@jira_key <> "." <> Mit.get_branch()
	end

	defp jira_template_key do
		@jira_key <> "-template"
	end

	defp get_saved_jira_url() do
		Mit.Config.read_from_local_env(construct_branch_jira_key())
	end

	defp get_suggested_jira_url() do
		case get_jira_url_template() do
			"http" <> rest -> String.replace("http" <> rest, @ticket_placeholder, Mit.get_branch())
			_ -> nil
		end
	end

	def set_jira_url_template(str) do
		str = str |> String.trim
		errors = validate_template_string(str)

		case errors do
			[] -> System.cmd("git", ["config", "--local", "--add", jira_template_key(), str])
			[_h|_] -> IO.puts "Unable to set template URL due to the following errors:\n" <> Enum.join(errors, "\n")
		end
	end

	defp validate_template_string(str) do
		str = str |> String.trim
		errors = []

		errors = case str do
			"http" <> _ -> errors
			_ -> add_error(errors, "The URL template must be a valid URL starting from `http`.")
		end

		errors = unless String.contains?(str, @ticket_placeholder) do
			add_error(errors, "The URL Template must include the string #{@ticket_placeholder} where branch names will be substituted.")
		else
			errors
		end

		errors
	end

	def validate_jira_url(url) do
		errors = []

		case url do
			"http" <> _ -> errors
			_ -> add_error(errors, "The URL template must be a valid URL starting from `http`.")
		end
	end

	defp add_error(errors, error) do
		errors ++ [error]
	end

	def get_jira_url_template do
		system_output = System.cmd("git", ["config", "--local", "--get", jira_template_key()], stderr_to_stdout: true)
		case system_output do
			{_, x} when x != 0 -> nil
			{"error: invalid key:" <> _, _} -> nil
			{nil, 0} -> nil
			{"", 0} -> nil
			{result, _} -> result |> String.trim
		end
	end

	defp format_template(url) do
		String.replace(url, Mit.get_branch(), IO.ANSI.red <> Mit.get_branch() <> IO.ANSI.default_color)
	end
end

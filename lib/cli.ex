defmodule Mit.CLI do
  use ExCLI.DSL, escript: true

	command :open do
		description("Tries to open the browser to the github repo for the `origin` remote")
		long_description("Should work for either SSH or HTTPS urls. Optionally specify remote name, defaults to origin.")

		option :remote, aliases: [:r], default: "origin", required: false
		option :branch, aliases: [:b], default: nil, required: false
		run context do
      Mit.open_github(context[:remote], context[:branch])
    end
	end

	command :jira do
		description("tries to open the browser to the JIRA ticket for this branch")
		long_description("(Assumes the branch name is equivalent to a JIRA ticket name)")

		option :help, aliases: [:h], type: :boolean, required: false
		option :clear_local_jira_url, aliases: [:c], type: :boolean, required: false
		option :set_jira_template, aliases: [:t], type: :string, required: false
		option :set_jira_url, aliases: [:u], type: :string, required: false

		run context do
			help = context[:help]
			jira_template = context[:set_jira_template]
			jira_url = context[:set_jira_url]
			clear_local_jira_url = context[:clear_local_jira_url]

			if help do
				IO.puts "Help for #{green("mit jira")} (or git jira if you've installed this to your local git config)"
				IO.puts ""
				IO.puts "- #{green("mit jira")} will open your browser to whatever location is stored in your project's configuration under the key #{blue("mit.jira_url.<branch_name>")}"
				IO.puts "\tIf #{blue("mit.jira_url.<branch_name>")} is not set, #{green("mit jira")} will ask you to enter one. You should paste the URL to the ticket this branch represents."
				IO.puts ""
				IO.puts "- #{green("mit jira -c")} will clear the currently set jira url stored under #{blue("mit.jira_url.<branch_name>")}."
				IO.puts ""
				IO.puts "- #{green("mit jira -u <url>")} will set the jira URL for this repo/branch under the git config name #{blue("mit.jira_url.<branch_name>")}."
				IO.puts "\tThis must be a valid URL starting with http."
				IO.puts ""
				IO.puts "- #{green("mit jira -t <template>")} will store a JIRA URL Template on your project."
				IO.puts "\tAny time you run #{green("mit jira")} in this project without having a #{blue("mit.jira_url.<branch_name>")} set it will suggest a url computed from this template."
				IO.puts "\tA valid template is any URL containing the string '<TICKET>' in place of the actual ticket ID."
				exit :shutdown
			end

			if clear_local_jira_url do
				IO.puts "Clearing local jira URL"
				Mit.Jira.clear_jira_url()
				IO.puts "Finished. Your local jira URL has been unset for this repo/branch."
				exit :shutdown
			end

			if jira_template do
				IO.puts "Setting global jira template to " <> jira_template
				Mit.Jira.set_jira_url_template (jira_template)
				exit :shutdown
			end

			if jira_url do
				IO.puts "Setting the JIRA url for this branch of of this repo to " <> jira_url
				Mit.Jira.confirm_jira_url(jira_url)
				exit :shutdown
			end

      Mit.open_jira()
    end
	end

	command :pulls do
		description("Opens the 'pull requests' github page for the given repo on the provided remote. (defaults to 'upstream')")

		option :remote, aliases: [:r], default: "upstream", required: false

		run context do
			Mit.open_pulls(context[:remote])
		end
	end

	defp green(str) do
		IO.ANSI.green <> str <> IO.ANSI.default_color
	end

	defp blue(str) do
		IO.ANSI.light_blue <> str <> IO.ANSI.default_color
	end
end

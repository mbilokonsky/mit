defmodule Mit.CLI do
  use ExCLI.DSL, escript: true

	command :open do
		description("Tries to open the browser to the github repo for the `origin` remote")
		long_description("Should work for either SSH or HTTPS urls. Optionally specify remote name, defaults to origin.")

		argument :remote_name, default: "origin", required: false
		argument :branch, default: nil, required: false
		run context do
      Mit.open_github(context.remote_name, context.branch)
    end
	end

	command :jira do
		description("tries to open the browser to the JIRA ticket for this branch")
		long_description("(Assumes the branch name is equivalent to a JIRA ticket name)")

    run _ do
      Mit.open_jira()
    end
	end
end

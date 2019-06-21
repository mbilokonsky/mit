# Mit

Mit is tooling around git that augments the CLI with a few useful sub-commands.

`mit open [remote_name=origin]` will open Safari to the github page for your
current repo, and if you're on a branch other than master it'll take you to that
branch. If you have multiple remotes configured you can pass the remote name in
as an optional argument and it'll open that remote, instead of origin. Note that
you'll get a 404 if the branch you're on locally doesn't exist on the target remote.

`mit jira` is opinionated in that it requires you to name your branches after JIRA
tickets, but if you do then running this in a project will open safari to that ticket.

Note that you need to set up an environment variable for this to work: `$JIRA_TEAM`

The generated URL is: `https://$JIRA_TEAM.atlassian.net/browse/<current branch name>`

## Installation

To use this, you must have Elixir installed and you must set your `JIRA_TEAM` variable.
If you don't have or don't want Elixir on your system, this may work if you just use the
compiled version included in this repo - see below.

Install it by running `bin/install.sh` - by default it'll install the `mit` application
to your system's `mix` bin folder, and it'll copy `git-open` and `git-jira` to your
`/usr/local/bin` to get them on your path.

Uninstall it by running `bin/uninstall.sh` - it'll remove the `mit` application as well as
both scripts from the default install locations.

### What gets installed?
* `./mit` -- this is the compiled executable that should be fully self-contained. Let me know
if this works/doesn't work and whether or not you have elixir installed.
* `scripts/git-open` -- this calls `mit open $1` for you, add it to your path and `git open` will work.
* `scripts/git-jira` -- this calls `mit jira` for you, add it to your path and `git jira` will work.

### Manual Setup - prepackaged executable
If you'd like, you can try to install this manually. `./mit` is a compiled executable, and in theory
ships with everything it needs to run - but I've not tested it. I've included it in the repo, though,
in case someone wants to use this but doesn't and/or can't have elixir on their system. Remember to
set the `$JIRA_TEAM` environment variable.

* `cp mit ~/bin` or some other location on your path
* `cp bin/git-* ~/bin` or some other location on your path

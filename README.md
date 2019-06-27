# Mit

Mit is tooling around git that augments the CLI with a few useful sub-commands.

`mit open [-r remote_name=master] [-b branch_name=get_current_branch()]` will open Safari to the github page for your current repo, and if you're on a branch other than master it'll take you to that branch. If you have multiple remotes configured you can pass the remote name in as an optional argument and it'll open that remote, instead of origin. Note that you'll get a 404 if the branch you're on locally doesn't exist on the target remote - so you can pass in the remote branch name, as well, if you'd like.

`mit pulls` will open the pull requests page in the `upstream` remote of the current branch.

`mit pr` will link you to a page where you can create a pull request to merge your current branch into upstream master. All aspects of this are configurable using command line flags, though:

1. `--body` optionally pre-populates the PR body for you. (not currently exposed through shell scripts)
2. `--title` optionally pre-populates the PR title for you. (not currently exposed through shell scripts)
3. `--source_branch` defaults to your current branch if not set. (if using shell scripts, `git pr -s my_branch`)
4. `--source_remote` defaults to `"origin"` if not set. (if using shell scripts, `git pr -n my_remote_name`)
5. `--target_branch` defaults to `"master"` if not set. (if using shell scripts, `git pr -b target_branch`)
6. `--target_remote` defaults to `"upstream"` if not set. (if using shell scripts, `git pr -r target_remote_name`)

`mit jira` will open Safari to the jira ticket associated with the current branch of the current repository. If you want, you can set the jira ticket of the current branch by running `mit jira -u <your ticket's URL>`. The first time you run it in a given branch of a given repository  it'll prompt you to specify a Jira ticket URL if it doesn't have one set.

But if you are the sort of person that likes to name your git branches after your jira tickets you get a bonus! You can run `mit jira -t <jira url template string>` and it'll autosuggest ticket URL's based on the schema you give it. A template must be a valid URL that uses the ticket ID somewhere in it, but you must replace the ticket ID with the string `"@ticket@"`.

Take the following example:

```bash
git clone git@github.com:foo/bar
cd bar
mit jira -t http://jira.com/tickets/@ticket@ # <-- note @ticket@ is required!
# --> Setting global jira template to https://jira.com/tickets/@ticket@
git checkout -b FOO-22
mit jira
# --> Do you want to use this URL as the JIRA ticket url for this branch of this repository?
# --> http://jira.com/tickets/FOO-22 y/n: # y
# opens browser to this url. will now always open this ticket for this branch on this repo.
```

If you make a mistake, or if the ticket for your branch changes, you can run `mit jira -c` and it'll unset the jira URL for the current branch, so that next time you run `mit jira` you'll be prompted to put in the correct one.

If you want to remove this from your repo entirely you can run `mit jira -x` and it'll remove all trace of itself from your local configuration.

## Installation

To use this, you must have Elixir installed. If you don't have or don't want elixir on your system, this may work if you just use the compiled version included in this repo - see below.

Install it by running `bin/install.sh` - by default it'll install the `mit` application to your system's `mix` bin folder, and it'll copy `git-open` and `git-jira` to your `/usr/local/bin` to get them on your path.

Uninstall it by running `bin/uninstall.sh` - it'll remove the `mit` application as well as both scripts from the default install locations.

### What gets installed?

* `./mit` -- this is the compiled executable that should be fully self-contained. Let me know if this works/doesn't work and whether or not you have elixir installed.
* `scripts/git-open` -- this calls `mit open` for you, add it to your path and `git open` will work.
* `scripts/git-jira` -- this calls `mit jira` for you, add it to your path and `git jira` will work.
* `scripts/git-pulls` -- this calls `mit pulls` for you, add it to your path and `git pulls` will work.
* `scripts/git-pr` -- this calls `mit pr` for you, add it to your path and `git pr` will work. *note conflicts with `HUB` if you have that installed.

### Manual Setup - prepackaged executable

If you'd like, you can try to install this manually. `./mit` is a compiled executable, and in theory ships with everything it needs to run - but I've not tested it. I've included it in the repo, though, in case someone wants to use this but doesn't and/or can't have elixir on their system. Remember to set the `$JIRA_TEAM` environment variable.

* `cp mit ~/bin` or some other location on your path
* `cp bin/git-* ~/bin` or some other location on your path


# Mit

Mit is tooling around git that augments the CLI with a few useful sub-commands.

## API

I just add these as I find them helpful. They don't always generalize and some of them are pretty idiosyncratic.

### open

`mit open [-r remote_name=master] [-b branch_name=get_current_branch()]` will open Safari to the github page for your current repo, and if you're on a branch other than master it'll take you to that branch. If you have multiple remotes configured you can pass the remote name in as an optional argument and it'll open that remote, instead of origin. Note that you'll get a 404 if the branch you're on locally doesn't exist on the target remote - so you can pass in the remote branch name, as well, if you'd like.

### pulls

`mit pulls` will open the pull requests page in the `upstream` remote of the current branch. TODO: parameterize this, `upstream` isn't always the remote name we want.

### pr

`mit pr` will link you to a page where you can create a pull request to merge your current branch into upstream master. All aspects of this are configurable using command line flags, though:

1. `--body` optionally pre-populates the PR body for you. (not currently exposed through shell scripts)
2. `--title` optionally pre-populates the PR title for you. (not currently exposed through shell scripts)
3. `--source_branch` defaults to your current branch if not set. (if using shell scripts, `git pr -s my_branch`)
4. `--source_remote` defaults to `"origin"` if not set. (if using shell scripts, `git pr -n my_remote_name`)
5. `--target_branch` defaults to `"master"` if not set. (if using shell scripts, `git pr -b target_branch`)
6. `--target_remote` defaults to `"upstream"` if not set. (if using shell scripts, `git pr -r target_remote_name`)
7. `--include-stats` will append the results of calling `Mit.Analyze.analyze_diff` to your PR body.

### jira

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

### Analyze

`mit analyze` is fun. It'll generate some JSON representing basic analytics over the log or diff you request. So if you just go into a repo and type `mit analyze` it'll look at the entire commit history and tell you how many files are included, how many of those are tests, and then a breakdown of file "types" (right now just extensions). You can parameterize it as follows:

* `-d [target to diff against, defaults to origin/master]` runs this against a diff, rather than against the log. Useful when preparing a PR to see what you're adding. If you use `-d` all other options will be ignored.
* `-l n` gets the log over the last `n` days. Useful to maintain a sliding window over your repo's history. If you use `-l`, then `-s` and `-u` are ignored. `-d` ignores this.
* `-a author_name` constrains the results to only those commits in the log written by `author_name`. Use this to analyze your own contributions. `-d` ignores this.
* `-s [date]` constrains the results to only those commits that have taken place since the provided date. `-l` ignores this. `-d` ignores this.
* `-u [date]` constrains the results to only those commits that took place before the provided date. `-l` ignores this. `-d` ignores this.


I wanna flesh this out so I can use it for thinks like making sure that I'm adding enough tests to my PRs, etc.

## Installation

To use this, you must have Elixir installed. If you don't have or don't want elixir on your system, this may work if you just use the compiled version included in this repo - see below.

Install it by running `bin/install.sh` - by default it'll install the `mit` application to your system's `mix` bin folder, and it'll copy `git-open` and `git-jira` to your `/usr/local/bin` to get them on your path.

Uninstall it by running `bin/uninstall.sh` - it'll remove the `mit` application as well as both scripts from the default install locations.

### What gets installed?

* `./mit` -- this is the compiled executable that should be fully self-contained. Let me know if this works/doesn't work and whether or not you have elixir installed.
* `scripts/git-open` -- this calls `mit open` for you, add it to your path and `git open` will work.
* `scripts/git-jira` -- this calls `mit jira` for you, add it to your path and `git jira` will work. (TODO: rename to `mit ticket`?)
* `scripts/git-pulls` -- this calls `mit pulls` for you, add it to your path and `git pulls` will work.
* `scripts/git-pr` -- this calls `mit pr` for you, add it to your path and `git pr` will work. Defaults to including `git analyze` stats in your PR body. *note conflicts with `HUB` if you have that installed.
* `scripts/git-analyze` -- this calls `mit analyze` for you, but the `-d` options is exposed as `-i`. So to analyze the diff between your current code and some_remote/some_branch you'd type `git analyze -i some_remote/some_branch` rather than `-d` as you would if you call `mit` directly.

### Manual Setup - prepackaged executable

If you'd like, you can try to install this manually. `./mit` is a compiled executable, and in theory ships with everything it needs to run - but I've not tested it. I've included it in the repo, though, in case someone wants to use this but doesn't and/or can't have elixir on their system. Remember to set the `$JIRA_TEAM` environment variable.

* `cp mit ~/bin` or some other location on your path
* `cp bin/git-* ~/bin` or some other location on your path

## TODO

The scripting solution I'm using is clearly silly. Hand-rolling all of these options is not scalable, and I think what I'd ultimately like to do is just create multiple releases of this CLI suite where each top-level command becomes its own executable. `mit-open`, `mit-jira`, `mit-pr` etc. Then I'd alias them as `git-*` instead of `mit-*` in a folder that's on my path somewhere.

`jira` should be expanded to `ticket` since there are other ticketing systems available.

`Mit.Config` should be more broadly used to store config variables and sensible defaults for all of the various `mit` tools. Ideally it can auto-suggest almost every value it requires once it's been initially configured, and for many people it should just work out of the box.

There should be more wizard-based workflows and less command-line options, maybe? But the options are easier to script. Hmm.

I want to add `Mit.Report` - this would use `Mit.Analyze` but it'd run it against the set of repos associated with a given report name. So I could set up `mit report artsy` and it would look at my global git config and see that `mit.report.artsy` is a list of 7 repos and it should give me a summary report over all of them.

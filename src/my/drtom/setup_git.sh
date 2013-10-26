cat <<'EOF' > ~/.gitconfig
[color]
  diff = auto
  status = auto
  branch = auto
  ui = true
[user]
	name = Thomas Schank
	email = DrTom@schank.ch

[diff]
  tool = default-difftool

[difftool]      
  prompt = false  

[alias]
	lg = log --oneline
  current-branch = !git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'
  ld = log --pretty=oneline --abbrev-commit --graph --decorate
  l = log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar, commited %cr %Creset'
  lol = log --pretty=oneline --abbrev-commit --graph --decorate
  staged = diff --cached
  track = checkout -t
  unstaged = diff
  co = checkout

[apply]
    whitespace = warn

[help]
    autocorrect = 1

[status]
    submodule = 1

[push]
    # Only push branches that have been set up to track a remote branch.
    #   default = current
[core]
	excludesfile = /Users/thomas/.gitignore_global

#[difftool "default-difftool"]
#  cmd = /Users/thomas/bin/gitdifftool $LOCAL $REMOTE
#[difftool "sourcetree"]
#	cmd = opendiff \"$LOCAL\" \"$REMOTE\"
#	path = 
#[mergetool "sourcetree"]
#	cmd = /Applications/SourceTree.app/Contents/Resources/opendiff-w.sh \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\"
#	trustExitCode = true
 
[push]
	default = matching
EOF


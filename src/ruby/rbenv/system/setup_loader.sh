cat <<'HEREDOC0' > /etc/profile.d/rbenv.sh
function load_rbenv {
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"
}
function unload_rbenv(){
export PATH=`ruby -e "puts ENV['PATH'].split(':').reject{|s| s.match(/\.rbenv/)}.join(':')"`
}
HEREDOC0

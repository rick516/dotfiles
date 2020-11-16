if [ -f ~/.bashrc ] ; then
. ~/.bashrc
fi

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'


# /Users/user_name/.rbenv/binに検索パスを通す
export PATH="$HOME/.rbenv/bin:$PATH"

# rbenvの初期化
eval "$(rbenv init -)"

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
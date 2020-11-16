#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

function rprompt-git-current-branch {
  local branch_name st branch_status

  if [ ! -e  ".git" ]; then
    # gitで管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# プロンプトの右側(RPROMPT)にメソッドの結果を表示させる
RPROMPT='`rprompt-git-current-branch`'

alias ll='ls -l'

# PATH
export PATH=/usr/local/bin:$PATH
export RUBY_CONFIGURE_OPTS="--with-readline-dir=$(brew --prefix readline) $RUBY_CONFIGURE_OPTS"
export PATH=/usr/local/bin:/usr/bin
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
eval "$(rbenv init -)"
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#tmux
function ssh() {
    # tmux起動時
    if [[ -n $(printenv TMUX) ]] ; then
        # 現在のペインIDを退避
        local pane_id=$(tmux display -p '#{pane_id}')
        # 接続先ホスト名に応じて背景色を切り替え
        if [[ `echo $1 | grep 'et'` ]] ; then
            tmux select-pane -P 'bg=colour52,fg=white'
        elif [[ `echo $1 | grep 'st'` ]] ; then
            tmux select-pane -P 'bg=colour58,fg=white'
        elif [[ `echo $1 | grep 'prod'` ]] ; then
            tmux select-pane -P 'bg=colour95,fg=white'
        fi

        # 通常通りssh続行
        command ssh $@

        # デフォルトの背景色に戻す
        tmux select-pane -t $pane_id -P 'default'
    else
        command ssh $@
    fi
}

# fzfの設定
 export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --select-1 --exit-0 --multi'

# fzf-cdr 
alias cdd='fzf-cdr'
function fzf-cdr() {
    target_dir=`cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf`
    target_dir=`echo ${target_dir/\~/$HOME}`
    if [ -n "$target_dir" ]; then
        cd $target_dir
    fi
}

# cdrの設定
autoload -Uz is-at-least
if is-at-least 4.3.11
then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*'      recent-dirs-max 500
  zstyle ':chpwd:*'      recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

# fgを使わずctrl+zで行ったり来たりする
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# fgをfzfで
alias fgg='_fgg'
function _fgg() {
    wc=$(jobs | wc -l | tr -d ' ')
    if [ $wc -ne 0 ]; then
        job=$(jobs | awk -F "suspended" "{print $1 $2}"|sed -e "s/\-//g" -e "s/\+//g" -e "s/\[//g" -e "s/\]//g" | grep -v pwd | fzf | awk "{print $1}")
        wc_grep=$(echo $job | grep -v grep | grep 'suspended')
        if [ "$wc_grep" != "" ]; then
            fg %$job
        fi
    fi
}

# git checkout branchをfzfで選択
alias co='git checkout $(git branch -a | tr -d " " |fzf --height 100% --prompt "CHECKOUT BRANCH>" --preview "git log --color=always {}" | head -n 1 | sed -e "s/^\*\s*//g" | perl -pe "s/remotes\/origin\///g")'

alias g='git'
alias gg="git prep -n"
alias ga='git add'
alias gd='git diff'
alias gs='git status'
alias gpl='git pull origin'
alias gps='git push origin'
alias gb='git branch'
alias gst='git status'
alias gco='git checkout'
alias gf='git fetch'
alias gc='git commit -m'

alias bi='bundle install'
alias be='bundle exec'
alias rs='bundle exec rails s'
alias rc='bundle exec rails c'
alias rdc='bundle exec rake db:create'
alias rdd='bundle exec rake db:drop'
alias rdm='bundle exec rake db:migrate'

alias nrd='npm run dev'
alias ns='nodemon server'
alias tsts='tmux source =/.tmux.conf'

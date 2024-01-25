ZSH_DISABLE_COMPFIX="true"

export ZSH="$HOME/.oh-my-zsh"

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
PROTOC_BIN=/usr/local/protoc/bin
LINKERD_BIN=$HOME/.linkerd2/bin
STRIPE_BIN=/usr/local/stripe
PYTHON_USER_BASE=$HOME/.local/bin
KREW_BIN=${KREW_ROOT:-$HOME/.krew}/bin
MYSQL_BIN=/home/linuxbrew/.linuxbrew/opt/mysql-client/bin

export GOPRIVATE=github.com/cyscale

export PATH=$PATH:$GOPATH:$GOBIN:$PROTOC_BIN:$LINKERD_BIN:$PYTHON_USER_BASE:$STRIPE_BIN:${HOME}/.bin:$KREW_BIN:$MYSQL_BIN

export KUBE_EDITOR=vim

ZSH_THEME="juanghurtado"

COMPLETION_WAITING_DOTS="true"

plugins=(
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  git
  nvm
  terraform
  aws
  docker
  docker-compose
  gcloud
  golang
  npm
  kubectl
  safe-paste
  helm
  redis-cli
  kubetail
  asdf
)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

alias sail="[ -f sail ] && bash sail || bash vendor/bin/sail"
alias python=/opt/homebrew/bin/python3
alias pip=/opt/homebrew/bin/pip
alias multipull="find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;"
alias ls="exa -l"
alias df=duf
alias man=tldr
alias jqd=jq -R 'fromjson? | select(.level!="DEBUG")'
alias jqerr=jq -R 'fromjson? | select(.level=="ERROR")'

awsDeleteSecret() {
  aws secretsmanager delete-secret --secret-id "$1" --force-delete-without-recovery
}

assumeRole() {
  local role="${2:-OrganizationAccountAccessRole}"

  export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
    $(aws sts assume-role \
      --role-arn "arn:aws:iam::${1}:role/${role}" \
      --role-session-name "$1" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text))
}

clearAWSSession() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
}

if [[ $(pwd) == /mnt/c/Users/* ]]; then
  cd ~
  dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus --nofork --nopidfile --syslog-only &
fi

fix_wsl2_interop() {
  for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
    if [[ -e "/run/WSL/${i}_interop" ]]; then
      export WSL_INTEROP=/run/WSL/${i}_interop
    fi
  done
}

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

if ((!${fpath[(I) / opt / homebrew / etc / bash_completion.d]})); then
  fpath=(/opt/homebrew/etc/bash_completion.d $fpath)
fi

source ~/.oh-my-zsh/completions/_az

exists() {
  command -v "$1" >/dev/null 2>&1
}

if exists thefuck; then
  eval $(thefuck --alias)
fi

autoload -U +X compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit -i
complete -o nospace -F /opt/homebrew/bin/aliyun aliyun

if [[ $OSTYPE == 'darwin'* ]]; then
  eval "$(mcfly init zsh)"
  if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
    echo "Updating /etc/pam.d/sudo to activate Touch ID authentication permissions from Terminal:"
    echo auth sufficient pam_tid.so | sudo tee -a /etc/pam.d/sudo
    echo "pam_tid.so permissions updated:

    $(cat /etc/pam.d/sudo)"
  fi
fi

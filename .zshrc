ZSH_DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="avit"
ZSH_THEME="agnoster"

DEFAULT_USER=$USER

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z npm osx brew extract git-flow dirhistory docker docker-compose)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

#########
# PERSO #
#########

if [ -f ~/.private_conf ]; then
    source ~/.private_conf
else
    print "404: ~/.private_conf"
fi

export PATH="$HOME/Library/Python/2.7/bin:$PATH"

POWERLEVEL9K_MODE='compatible'

## NPM

NPM_PACKAGES="${HOME}/.npm-packages"

PATH="$NPM_PACKAGES/bin:$PATH"

# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
unset MANPATH # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

## Functions
function mkdird() { mkdir $1 && cd $1 }

## Alias
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias rmrf="rm -rf"

alias sbtc="sbt compile"
alias sbtr="sbt run"
alias sbtt="sbt test"

## Added private GitHub config:
# GITHUB_AUTH_ID
# GITHUB_AUTH_SECRET

## Git custom commands
export PATH="$PATH:$HOME/git-plugins"
alias glolm="glol master.."
alias glolmd="glol master_dev.."
alias glold="glol develop.."
alias gcav="gcaj \":bookmark: bump version\""
alias ggca="gitmoji -c"
alias gcmd="git checkout master_dev"

function lastcommit() {
  glol | head -1 | awk '{print $2}' | pbcopy
}

function createBranchFromOrigin() { 
  branch="issues/$1/$2"
  git checkout -b $branch origin/master_dev
}

function gfeat() {
  createBranchFromOrigin $1 $2
}

function ghotfix() {
  git checkout -b hotfix/$1 origin/staging
}

function gfixup() { git commit -a --fixup `git rev-parse HEAD` }

function gcmm() {
  oldFeatureBranch=`git branch | grep "*" | sed 's/^\* //'`
  gcm
  ggl
  git branch -d $oldFeatureBranch
}

function gcmmd() {
  oldFeatureBranch=`git branch | grep "*" | sed 's/^\* //'`
  gcmd
  ggl
  git branch -d $oldFeatureBranch
}

function gcdd() {
  oldFeatureBranch=`git branch | grep "*" | sed 's/^\* //'`
  gcd
  ggl
  git branch -d $oldFeatureBranch
}

function gcaj() {
  branch=$(git branch --show-current)
  if [[ $branch =~ [A-Z]+-[0-9] ]]; then
      jira=$(echo "$branch" | grep -e "[A-Z]\+-[0-9]\+" -o)
      git commit -am "$jira $1"
  else
      git commit -am "$1"
  fi
}

export HOMEBREW_INSTALL_CLEANUP=true
function brew_cleanup() {
  brew update
  brew upgrade
  brew cleanup -s
  brew cask cleanup
  brew doctor
  brew missing
}

## Personal bin folder
export PATH="$PATH:$HOME/bin"

## Git custom editor
export VISUAL="code -w"
export EDITOR="$VISUAL"

alias dps='docker ps'
alias dimg='docker images'
alias d='docker'
function docker_rm_all() {
  echo "Relax, it's going to take a while..."
  docker rmi $(docker images -q) -f
  docker rm $(docker ps -q -f 'status=exited')
  docker rmi $(docker images -q -f "dangling=true")
  docker volume rm $(docker volume ls -qf dangling=true)
  docker system prune -a
}

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias dcu='docker-compose up'
alias dcd='docker-compose down'

export GROOVY_HOME=/usr/local/opt/groovy/libexec

# Haskell
export PATH=$PATH:$HOME/.local/bin

# IMG Arena

## virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper_lazy.sh

## Test EC2 SSH access
ssh_test_ec2 () {
	ssh -i ~/.ssh/aws-test.pem ec2-user@"$1"
}

## Test artefact publication
function jar2aws() {
  APP=${PWD##*/}
  COMMIT=$(git rev-parse --short=7 HEAD)
  sbt 'set test in assembly := {}' assembly && aws s3 cp target/scala-2.*/*-$COMMIT.jar s3://dde-artifacts/jars/$APP/ --profile default
}

## Set up sdkman
source "$HOME/.sdkman/bin/sdkman-init.sh"

## psql
export PATH=$PATH:/usr/local/Cellar/libpq/13.1/bin
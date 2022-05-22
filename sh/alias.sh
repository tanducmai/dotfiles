# Aliases for bash script
# Language: sh

# """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#                    _    _     ___    _    ____  _____ ____
#                   / \  | |   |_ _|  / \  / ___|| ____/ ___|
#                  / _ \ | |    | |  / _ \ \___ \|  _| \___ \
#                 / ___ \| |___ | | / ___ \ ___) | |___ ___) |
#                /_/   \_\_____|___/_/   \_\____/|_____|____/
#
# """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi


# Add an "alert" alias for long running commands.
# Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ls / exa aliases
alias sl='sl && cl && ls'
alias ls='exa --git-ignore'
alias l='ls'
alias ll='exa -alhF'
alias la='ll --git'
alias tree='exa --tree --long'

# other aliases
alias ..='cd ..'
alias ....='cd ../..'
alias cd..='cd ..'
alias cd....='cd ../..'
alias e='vim -o'
alias E='vim -o'
alias cc='cd /mnt/c/Users/TanDucMai/OneDrive\ -\ Eynesbury && clear && ls'
alias website='cd /mnt/c/Users/TanDucMai/OneDrive\ -\ \
Eynesbury/Desktop/myportfolio && clear && ls'
alias VIM='cd ~/.vim && clear && ls'
alias PY='cd ~/python_projects && clear && ls'
alias view='wslview'  # View a file in another app
alias open='xdg-open' # Open a file with default app, or view a file within terminal'
alias opne='xdg-open' # In case I mistype the word 'open'
youtube='https:\/\/youtube.com'
facebook='https:\/\/facebook.com'
alias rihc='rich'
alias bashrc='vim ~/.vim/bash/bashrc'
alias vimrc='vim ~/.vim/vimrc'
alias gitconfig='vim ~/.vim/git/gitconfig'
alias py='python3'
alias ex='exit'
alias cl='clear'
alias gsh='git-sh'
alias gitsh='git-sh'
alias gst='git st'
alias gcc='git cc'
alias gcm='git cm'
alias gdiff='git diff'
alias gadd='git add'
alias gcl='git clone'
alias gco='git checkout'
alias gpull='clear && printf "Wait for remote content to be fetched from Github\
 ...\n--------------------\n" && git pull'
alias gpush='clear && printf "Wait for the local commits to be pushed to GitHub\
 ...\n--------------------\n" && git push'
alias gpsuh='gpush'
alias gpuhs='gpush'
alias upgrade='clear && \
 printf "Check for updates to the Operating System ...\n --------------------\n" && \
 sudo apt update && sudo apt full-upgrade -y && \
 sudo apt autoremove -y && sudo apt autoclean && \
 printf " --------------------\nCheck for updates to VIM submodules ..." && \
 git -C ~/.vim submodule update --init --recursive --remote && \
 printf "\n --------------------\nCheck for updates to PIP package manager ...\n" && \
 python -m pip install --upgrade pip && cowsay You are up to date!'
alias hugolive='clear && printf "Wait for the site to be published\
 ...\n--------------------\n" && hugo server --noHTTPCache --disableFastRender\
 --buildDrafts'
alias ConvertREADME.mdToPDF='clear && printf "Wait for README.md to be converted\
 ...\n--------------------\n" && cp README.md ../pandoc_md_to_pdf/ && cd\
 ../pandoc_md_to_pdf && ./md2pdf_syn_bullet.sh README.md sample_output.pdf\
 && mv sample_output.pdf ../ && rm README.md && cd ..'
alias autopep8='printf "Finish formatting ...\n" && autopep8 --in-place -r -a -a'
alias githubtrending='starcli -S en -L table -l python -r 5 -d today'
alias sqlformat='sqlformat -s --reindent --keywords upper --identifiers lower'
alias sortdict='printf "Finish sorting dictionary ...\n" && \
  cd ~/.vim/dictionary/sort/ && ./wordlist && ./spf && cd ~/.vim'
alias pipinstall='python3 -m pip install --user --upgrade'
alias pytree='python3 ~/.vim/py/tree.py'
alias pydownload='python3 ~/.vim/py/downloader.py'
alias pycalc='python3 ~/.vim/py/calculator.py && rm textual.log'
alias pyview='python3 ~/.vim/py/code_viewer.py && rm textual.log'
alias ddate='date +"%R%p - %a, %B %d, %Y"'
alias dday='date +"%d-%m-%Y"'
alias toilet='toilet -t -f mono12 --filter border:metal -F metal'
alias toiletgay='toilet --filter border:gay -F gay'
alias alllowercase="rename 'y/A-Z/a-z/' *"
alias alluppercase="rename 'y/a-z/A-Z/' *"
alias zzz='zoxide'

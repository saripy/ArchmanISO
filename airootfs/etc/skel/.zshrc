#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


#aliases
alias pac="sudo pacman -S"
alias pacs="sudo pacman -Ss"
alias pacu="sudo pacman -Syy"
alias update="sudo pacman -Syyu"
alias mirrors="sudo reflector --verbose --latest 15 --sort rate --save /etc/pacman.d/mirrorlist"
alias upgrade="sudo reflector --verbose --latest 15 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syyu"
alias clean="sudo pacman -Scc"
alias remove="sudo pacman -Rsnc"


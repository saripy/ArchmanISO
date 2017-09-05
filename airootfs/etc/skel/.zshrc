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
alias update="sudo pacman -Syu"
alias upgrade="sudo pacman -Syyu"
alias mirrors="sudo reflector --verbose --latest 20 --sort rate --save /etc/pacman.d/mirrorlist & pacman -Syyu"

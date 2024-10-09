export QT_QPA_PLATFORMTHEME="qt5ct"
# export EDITOR=/usr/local/bin/nvim
export EDITOR=/usr/bin/nvim

export PATH="$HOME/.cargo/bin:$PATH"

#golang
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="/mnt/fast/projects/go"
export PATH="$PATH:$GOPATH/bin"
export GOPRIVATE="git.ais-servis.cz"
export JDTLS_HOME="/mnt/fast/projects/jdtls"

dockermem() { docker stats --no-stream --format '{{.MemUsage}}' | awk '{print $1}' | sed 's/B//'| sed 's/\./,/' | numfmt --from=iec-i | awk '{s+=$1} END {print s}' | numfmt --to=iec-i; }

alias vim=nvim
alias gpureload="sudo rmmod nvidia_uvm ; sudo modprobe nvidia_uvm"
xset r rate 200 25

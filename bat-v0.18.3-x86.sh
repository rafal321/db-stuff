#!bin/bash
# curl -L https://github.com/sharkdp/bat/releases/download/v0.18.3/bat-v0.18.3-x86_64-unknown-linux-musl.tar.gz -o bat-v0.18.3-x86.tar.gz &&
curl -L https://raw.githubusercontent.com/rafal321/db-stuff/master/bat-v0.18.3-x86.tar.gz -o bat-v0.18.3-x86.tar.gz &&
tar xzf bat-v0.18.3-x86.tar.gz &&
sudo cp bat-v0.18.3-x86_64-unknown-linux-musl/bat /usr/local/bin/ &&
bat --version
sleep 1

cat <<EOF >> ~/.bashrc
alias bat='bat --style=plain'
alias y='bat -lyaml -p'
alias batl='bat -llog -p'
alias k='bat -pl nix'
alias kk='bat -pl gvy'
alias kkk='bat -pl hs'
alias tree='tree -C'
export PS1='[\[\033[0;33m\]\u@\h\[\033[00m\]:\[\033[00;36m\]\W\[\033[00m\]]\[\033[01;94m\]\[\033[00m\]\$ ' # Yellow
EOF
source ~/.bashrc

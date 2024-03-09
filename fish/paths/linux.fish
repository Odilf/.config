source ~/.config/fish/paths/universal.fish

# brew
set PATH $PATH ~/.linuxbrew/bin
set PATH $PATH /home/linuxbrew/.linuxbrew/bin

# pnpm
set -x PNPM_HOME ~/.local/share/pnpm/store/v3/
set PATH $PATH $PNPM_HOME

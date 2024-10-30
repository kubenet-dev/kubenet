# atuin
# bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/download/v18.3.0/atuin-installer.sh | sh

# theme
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh-autosuggestions and autocompletions
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# syntax highlighting
git clone --depth 1 https://github.com/z-shell/F-Sy-H.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H

###
### Shell completions
###
# generate containerlab completions
containerlab completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_containerlab"
# add clab alias to the completions
sed -i 's/compdef _containerlab containerlab/compdef _containerlab containerlab clab/g' /home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_containerlab
# generate gnmic completions
gnmic completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_gnmic"
# generate gnoic completions
gnoic completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_gnoic"
# generate gh completions
gh completion -s zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_gh"
# kubectl completions
kubectl completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_kubectl"
# kind completions
kind completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_kind"
# kubenetctl completions
kubenetctl completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_kubenetctl"
# choreoctl completions
choreoctl completion zsh > "/home/vscode/.oh-my-zsh/custom/plugins/zsh-autocomplete/Completions/_choreoctl"
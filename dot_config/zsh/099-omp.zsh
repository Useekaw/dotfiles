# oh-my-posh
if [ -x "$(command -v oh-my-posh)" ]; then
    eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/pure.omp.json)"
fi


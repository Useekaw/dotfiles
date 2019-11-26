uz() {
    [[ -d $CACHE_DIR ]] || mkdir -p $CACHE_DIR
    antibody bundle <$ZSH_CONFIG_DIR/plugins.txt >$CACHE_DIR/.zsh_plugins.sh
    antibody update
}

md() {
    mkdir -p "$1"
    cd "$1"
}

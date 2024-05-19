''
case $- in
  *i*)
    if [ -z "$DISPLAY" ] && [ -z "$TMUX" ]; then
      exec tmux
    fi
    ;;
esac
''

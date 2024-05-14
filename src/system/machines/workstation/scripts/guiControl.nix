''
function ui() {
  case $1 in
    on)
      sudo systemctl set-default graphical.target
      sudo systemctl start graphical.target
      ;;
    off)
      sudo systemctl set-default multi-user.target
      sudo systemctl isolate multi-user.target
      ;;
    *)
      echo "Usage: $0 {on|off}"
      ;;
  esac
}
''

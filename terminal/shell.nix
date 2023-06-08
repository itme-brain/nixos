{ pkgs ? import <nixpkgs> {} }:


with pkgs;
mkShell {
  buildInputs = [
    bash neovim alacritty
    terminus-nerdfont noto-fonts-emoji
    direnv nix-direnv
    lsd git gnupg lazygit
  ];

  shellHook = ''
    echo "Preparing your environment, Bryan..."

    wget https://github.com/itme-brain/nixos/tree/yolo-allin/terminal/configs.tar.gz
    
    tar -xzvf configs.tar.gz -C .

    if [ -f ~/.bashrc ] || [ -f ~/.config/alacritty/alacritty.yml ] || [ -d ~/.config/nvim ] || [ -f ~/.gitconfig ]; then
      echo "Backing up existing config files..."
      echo "You can find them at ~/your_configs.bak"
      mkdir -p ~/your_configs.bak
    fi

    [ -f ~/.bashrc ] && mv ~/.bashrc ~/your_configs.bak/bashrc.bak
    mv configs/bashrc ~/.bashrc
    
    [ -f ~/.config/alacritty/alacritty.yml ] && mv ~/.config/alacritty ~/your_configs.bak/alacritty.bak
    mv configs/alacritty ~/.config/alacritty
    
    [ -d ~/.config/nvim ] && mv ~/.config/nvim ~/your_configs.bak/nvim.bak
    mv configs/nvim ~/.config/nvim
    
    [ -f ~/.gitconfig ] && mv ~/.gitconfig ~/your_configs.bak/gitconfig.bak
    mv configs/gitconfig ~/.gitconfig

    gpg --import configs/pub.key

    rm configs.tar.gz
    rm configs
    find . -type d -empty -delete

    if [ -d ~/your_configs.bak ]; then
      echo "Restore script has been created..."
      cat > ~/your_configs.bak/restore.sh << EOF
      #!/bin/sh
      # To restore the original config, run the script using './restore.sh'
      [ -f bashrc.bak ] && mv bashrc.bak ~/.bashrc
      [ -d alacritty.bak ] && mv alacritty.bak ~/.config/alacritty
      [ -d nvim.bak ] && mv nvim.bak ~/.config/nvim
      [ -f gitconfig.bak ] && mv gitconfig.bak ~/.gitconfig
      EOF
      chmod +x ~/your_configs.bak/restore.sh
    fi

    echo "Terminal ready."
    echp "Run `ldv` to get some existing environments."
  '';
}

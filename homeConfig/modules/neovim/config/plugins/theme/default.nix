{ pkgs, lib, ... }:

let  

    panvimdoc = pkgs.fetchFromGitHub {
      owner = "kdheepak";
      repo = "panvimdoc";
      rev = "v3.0.6";
      sha256 = "0smij72mpd1lm6akjzkmh2z76xfgn86n7n1ah36fz16p1krc1nwv";
    };
    github-theme = pkgs.stdenv.mkDerivation {
      pname = "github-theme";
      version = "1.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "projekt0n";
        repo = "github-nvim-theme";
        rev = "v1.0.0";
        sha256 = "1b9fac3ajqr9i5291k3z3pgrh3l08ga1ghdw05s1nq3xvbzcicn5";
      };
    buildInputs = [ pkgs.makeWrapper ];

    buildPhase = ''
      # replace misc/panvimdoc with our pre-fetched version
      rm -rf misc/panvimdoc
      ln -s ${panvimdoc} misc/panvimdoc

      # carry on with the build as normal
      make
    '';

    installPhase = ''
      # install the plugin to $out
      mkdir -p $out
      cp -r * $out
    '';

    meta = with lib; {
      description = "A dark theme for Neovim";
      homepage = "https://github.com/projekt0n/github-nvim-theme";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };

in
[
  {
    plugin = github-theme;
    config = '' 
    lua << EOF
      vim.cmd('colorscheme github_dark_high_contrast')
    EOF
    '';
  }
]


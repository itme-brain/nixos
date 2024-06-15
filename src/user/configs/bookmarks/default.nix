[
  {
    name = "Toolbar";
    toolbar = true;
    bookmarks = [
      {
        name = "ArchWiki";
        url = "wiki.archlinux.org/";
        tags = [ "dev" "linux" ];
        keyword = "arch";
      }
      {
        name = "NixOS";
        bookmarks = [
          {
            name = "Nixpkgs";
            url = "search.nixos.org/packages";
            tags = [ "nix" "dev" "linux" ];
            keyword = "pkgs";
          }
          {
            name = "Home Manager Options";
            url = "nix-community.github.io/home-manager/options.xhtml";
            tags = [ "nix" "dev" "linux" ];
            keyword = "hm";
          }
        ];
      }
      {
        name = "Gentoo Wiki";
        url = "wiki.gentoo.org";
        tags = [ "dev" "linux" ];
        keyword = "gentoo";
      }
      {
        name = "Email";
        bookmarks = [
          {
            name = "Gmail";
            url = "gmail.com";
            tags = [ "google" "email" ];
            keyword = "gmail";
          }
          {
            name = "ProtonMail";
            url = "mail.protonmail.com";
            tags = [ "email" ];
            keyword = "email";
          }
        ];
      }
      {
        name = "Outlook";
        url = "outlook.office365.com";
        tags = [ "work" "email" ];
        keyword = "work";
      }
      {
        name = "Teams";
        url = "teams.microsoft.com";
        tags = [ "work" ];
        keyword = "teams";
      }
      {
        name = "Twitter";
        url = "x.com";
        tags = [ "social" ];
        keyword = "x";
      }
      {
        name = "Reddit";
        url = "reddit.com";
        tags = [ "social" ];
        keyword = "reddit";
      }
      {
        name = "Substack";
        url = "substack.com";
        tags = [ "social" "blogging" ];
        keyword = "blog";
      }
      {
        name = "Nostr";
        bookmarks = [
          {
            name = "Socials";
            bookmarks = [
              {
                name = "Primal";
                url = "primal.net";
                tags = [ "social" "nostr" "bitcoin" ];
                keyword = "nostr";
              }
            ];
          }
        ];
      }
    ];
  }
]

[
  {
    name = "toolbar";
    toolbar = true;
    bookmarks = [
      {
        name = "ArchWiki";
        url = "https://wiki.archlinux.org/";
        tags = [ "dev" "linux" "docs" ];
      }
      {
        name = "NixOS";
        bookmarks = [
          {
            name = "Nixpkgs";
            url = "https://search.nixos.org/packages";
            tags = [ "nix" "dev" "linux" ];
            keyword = "pkgs";
          }
          {
            name = "Home Manager Options";
            url = "https://nix-community.github.io/home-manager/options.xhtml";
            tags = [ "nix" "dev" "linux" ];
            keyword = "hm";
          }
          {
            name = "Nix";
            bookmarks = [
              {
                name = "nix.dev";
                url = "https://nix.dev";
                tags = [ "nix" "dev" "docs" ];
                keyword = "nix";
              }
            ];
          }
        ];
      }
      {
        name = "Gentoo Wiki";
        url = "https://wiki.gentoo.org";
        tags = [ "dev" "linux" "docs" ];
        keyword = "gentoo";
      }
      {
        name = "Email";
        bookmarks = [
          {
            name = "Gmail";
            url = "https://gmail.com";
            tags = [ "google" "email" ];
            keyword = "gmail";
          }
          {
            name = "ProtonMail";
            url = "https://mail.protonmail.com";
            tags = [ "email" "personal" "work" ];
            keyword = "email";
          }
        ];
      }
      {
        name = "Outlook";
        url = "https://outlook.office365.com";
        tags = [ "work" "email" "microsoft" ];
        keyword = "work";
      }
      {
        name = "Teams";
        url = "https://teams.microsoft.com";
        tags = [ "work" "microsoft" ];
        keyword = "teams";
      }
      {
        name = "Twitter";
        url = "https://x.com";
        tags = [ "social" "forum" ];
        keyword = "x";
      }
      {
        name = "Reddit";
        url = "https://reddit.com";
        tags = [ "social" "forum" ];
        keyword = "reddit";
      }
      {
        name = "Substack";
        url = "https://substack.com";
        tags = [ "social" "blogging" "personal" ];
        keyword = "blog";
      }
      {
        name = "Youtube";
        url = "https://youtube.com";
        tags = [ "social" "entertainment" "google" ];
        keyword = "youtube";
      }
      {
        name = "Twitch";
        url = "https://twitch.com";
        tags = [ "social" "entertainment" "amazon" ];
        keyword = "twitch";
      }
      {
        name = "Amazon";
        url = "https://amazon.com";
        tags = [ "shopping" "amazon" ];
        keyword = "amazon";
      }
      {
        name = "Nostr";
        url = "https://primal.net";
        tags = [ "social" "nostr" "bitcoin" ];
        keyword = "nostr";
      }
      {
        name = "ChatGPT";
        url = "https://chat.openai.com";
        tags = [ "dev" "ai" "microsoft" ];
        keyword = "ai";
      }
      {
        name = "Dev";
        bookmarks = [
          {
            name = "Github";
            url = "https://github.com";
            tags = [ "dev" "work" "personal" "microsoft" ];
            keyword = "git";
          }
          {
            name = "Gist";
            url = "https://gist.github.com";
            tags = [ "dev" "work" "personal" "microsoft" "blogging" ];
            keyword = "gist";
          }
          {
            name = "Stack Overflow";
            url = "https://stackoverflow.com";
            tags = [ "dev" "work" "forum" ];
          }
          {
            name = "Tools";
            bookmarks = [
              {
                name = "Namecheap";
                url = "https://namecheap.com";
                tags = [ "dev" "shopping" "hosting" ];
              }
              {
                name = "LetsEncrypt";
                url = "https://letsencrypt.com";
                tags = [ "dev" "hosting" ];
              }
              {
                name = "Documentation";
                bookmarks = [
                  {
                    name = "MDN";
                    url = "https://developer.mozilla.org";
                    tags = [ "dev" "docs" ];
                    keyword = "mdn";
                  }
                  {
                    name = "DevDocs";
                    url = "https://devdocs.io";
                    tags = [ "dev" "docs" ];
                    keyword = "docs";
                  }
                  {
                    name = "References";
                    bookmarks = [
                      {
                        name = "ASCII Table";
                        url = "https://asciitable.com";
                        tags = [ "dev" ];
                        keyword = "ascii";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      }
      {
        name = "Financials";
        bookmarks = [
          {
            name = "Fidelity";
            url = "https://fidelity.com";
            tags = [ "banking" ];
            keyword = "bank";
          }
          {
            name = "Chase";
            url = "https://chase.com";
            tags = [ "banking" ];
          }
          {
            name = "Wells Fargo";
            url = "https://wellsfargo.com";
            tags = [ "banking" ];
          }
          {
            name = "Crapto";
            bookmarks = [
              {
                name = "Coinbase";
                url = "https://coinbase.com";
                tags = [ "banking" ];
              }
            ];
          }
        ];
      }
    ];
  }
]

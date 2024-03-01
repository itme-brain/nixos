{ lib, pkgs, ... }:

# Replace symlink at root of repo with user configs
{
  options = {
    user = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "bryan";
        shell = pkgs.bash;

        groups = [
          "wheel" "networkmanager" "home-manager" "input"
        ];

        sshKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDl4895aB9P5p/lp8Hq5rHun4clvhyTSHFi3U2d6OOBoW5Fm+VcQnW/xbjmCBsXk5BdiowsBxQhwnzdfz/KJL7J5RobomUEaVRwb9UwT88eJveLp14BG8j2J3SjfyhrCX+4jkPx0bPQk1HGcuYY+tPEXf1q/ps88Dhu0CARBIzYQOTYY6b1qWzxpDoFZGHjKG8g5iY6FIu65yKKvvVy1f8IgZ3l3IpwBWVamxgkTcYY0QYSrmzo1n7TXxwrWbvenAqBsQ0cBPs+gVa3uIr+1TJl0Az5SElBVGu3LvUdlk58trtPUj6TQR3YUkg7Vjll7WHOdqhux5ZQNhjkOsHerf0Tw86e6cEzgeTuIbQHIb0LcsUunwKcuh2+au7RO599cvHn0+xZE5MZBxloDDaJ3JsiliM8kyPP/U3ERj03cWLW7BqbT+sfjAOl21RCzk0iQxk1wt/8VmtCr9Adv7IyrtaYvf/bwRP+g+9ldmzKGt8Mdb605uVzZ70H/LLm17f40Te+QHaex5by/6p6cuwEEZtgIg53Wpglu0rA6UxrBfQEHKl/Jt3FLeE0mnEyYkkR2MnHNtyWRIXtuqYZMAm2Ub1pFHH7jQV1gGiDVTw6a2eIwK21a/hXtRjFUpFd1nB1n+KNfJBE4zT3wm3Ud7mKw/6rWnoRyhYZvGXkFdp+iEs49Q=="
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK2ROz7EVvE+nzF5k9EYZ2v3JhBzk058uh3QJTzcG4t70fkZgh9y56AOx26eXlKQWuuV05e8EkWRuVI8gfA2ROI="
        ];

        gitConfig = {
          userName = "Bryan Ramos";
          userEmail = "bryan@ramos.codes";
          signing = {
            key = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";
            signByDefault = true;
          };

          extraConfig = {
            init = { defaultBranch = "master"; };
            mergetool = {
              lazygit = {
                cmd = "lazygit";
                trustExitCode = true;
              };
            };
            merge = {
              tool = "lazygit";
            };
            safe = {
              directory = "/etc/nixos";
            };
          };

          ignores = [
            "node_modules"
            ".direnv"
            "dist-newstyle"
            ".nuxt/"
            ".output/"
            "dist"
          ];
        };

        pgpKey = {
          text = import ./pgpKey.nix;
          trust = 5;
        };
      };
    };
  };
}

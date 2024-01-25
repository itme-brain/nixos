{
  enable = true;
  userName = "Bryan Ramos";
  userEmail = "bryan@ramos.codes";
  signing = {
    key = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";
    signByDefault = true;
  };

  extraConfig = {
    init = { defaultBranch = "main"; };
    mergetool = {
      lazygit = {
        cmd = "lazygit";
        trustExitCode = true;
      };
    };
    merge = {
      tool = "lazygit";
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
}

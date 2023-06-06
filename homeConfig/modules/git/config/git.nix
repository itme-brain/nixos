{
  enable = true;
  userName = "Bryan Ramos";
  userEmail = "bryan@ramos.codes";
  signing.key = "F1F3466458452B2DF351F1E864D12BA95ACE1F2D";

  extraConfig = {
    init = { defaultBranch = "main"; };
  };

  ignores = [
    "node_modules"
  ];
}

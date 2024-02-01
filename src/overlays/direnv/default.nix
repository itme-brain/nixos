final: prev: {
  direnv = prev.direnv.overrideAttrs (oldAttrs: {
    src = builtins.fetchFromGithub {
      owner = "itme-brain";
      repo = oldAttrs.src.repo;
      rev = "889db6f94f906004428b80ebbc301337bf5b9143";
      sha256 = "0i04zrqbsg9hpl4dqb5c48iz051m5cxjxklri1f05agvbyfi3i1q";
    };
  });
}

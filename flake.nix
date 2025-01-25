{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: rec {
    devShells.aarch64-darwin.default = nixpkgs.lib.mkShell {
      buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
        git
        neovim
        tree
        terraform
        zoxide
        jq
        tmux
        moreutils
        timewarrior
        mpv
        awscli
        direnv
        htop
        ripgrep
        neomutt
        sc-im
        tshark
        pandoc
        texlive.combined.scheme-full
        kubectl
      ];

      shellHook = ''
        cd /Users/david/@/
      '';
    };
  };
}

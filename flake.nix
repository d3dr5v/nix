{
  description = "Global development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
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
        kubectl
        pandoc
#texlive.combined.scheme-full
        yt-dlp
        ranger
      ];

      shellHook = ''
        if [ -z "$OPENAI_API_KEY" ]; then
          echo "OPENAI_API_KEY is not set. Retrieving from AWS Secrets Manager..."

          SECRET_VALUE=$(AWS_PROFILE=davidroussov aws secretsmanager get-secret-value --secret-id "openai.api_key" --query 'SecretString' --output text 2>/dev/null)

          if [ $? -ne 0 ]; then
              exit 1
          fi

          export OPENAI_API_KEY="$SECRET_VALUE"
        fi

        
        cd /Users/david/@/

        /bin/zsh
      '';
    };
  };
}

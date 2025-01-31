
{
  description = "Global development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
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
        yt-dlp
        ranger
        ncdu
        rtorrent
        elinks
        nodejs_23
        texliveTeTeX
        epub2txt2
        gh
        zsh
        rustc
        cargo
	openssh
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

        if [ -z "$KAGI_API_KEY" ]; then
          echo "KAGI_API_KEY is not set. Retrieving from AWS Secrets Manager..."

          SECRET_VALUE=$(AWS_PROFILE=davidroussov aws secretsmanager get-secret-value --secret-id "kagi.api_key" --query 'SecretString' --output text 2>/dev/null)

          if [ $? -ne 0 ]; then
              exit 1
          fi

          export KAGI_API_KEY="$SECRET_VALUE"
        fi

        # Oh My Zsh installation
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
          echo "Installing Oh My Zsh..."
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
          rm -f "$HOME/.zshrc"
          ln -s "$HOME/@/dot/.zshrc" "$HOME/.zshrc"
        fi

        zsh
      '';
    };
  };
}

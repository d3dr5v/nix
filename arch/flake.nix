
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
        texliveTeTeX
        epub2txt2
        gh
        zsh
        openssh
        rustup
        lazygit
        up
        podman
        podman-compose
        nodejs_23
        python313
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

	  git clone https://github.com/jeffreytse/zsh-vi-mode "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
        fi

        # rustup initialization
        if [ ! -d "$HOME/.rustup" ]; then
          rustup default stable
        fi
        
        # Python crap
        if [ ! -d "$HOME/.venv" ]; then
          echo "Installing python packages"
          python -m venv ~/.venv
          source ~/.venv/bin/activate
          pip install git+https://github.com/marcolardera/chatgpt-cli
          deactivate
        fi

        zsh
      '';
    };
  };
}

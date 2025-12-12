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
        yt-dlp
        ranger
        ncdu
        rtorrent
        elinks
        texliveTeTeX
        epub2txt2
        gh
        direnv
        zsh
        podman
        podman-compose
        nodejs_24
        python313
        up
        procps
        ffmpeg
        emacs
        tig
      ];

      shellHook = ''
        if [ -z "$ANTHROPIC_API_KEY" ]; then
          echo "ANTHROPIC_API_KEY is not set. Retrieving from AWS SSM Parameter Store..."

          ANTHROPIC_API_KEY_VALUE=$(
            AWS_PROFILE=davidroussov \
            aws ssm get-parameter \
              --name "/anthropic/api_key" \
              --with-decryption \
              --query 'Parameter.Value' \
              --output text 2>/dev/null
          )

          if [ $? -ne 0 ] || [ -z "$ANTHROPIC_API_KEY_VALUE" ]; then
            echo "Failed to retrieve ANTHROPIC_API_KEY from SSM Parameter Store"
            exit 1
          fi

          export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_VALUE"
        fi

        if [ -z "$OPENAI_API_KEY" ]; then
          echo "OPENAI_API_KEY is not set. Retrieving from AWS SSM Parameter Store..."

          OPENAI_API_KEY_VALUE=$(
            AWS_PROFILE=davidroussov \
            aws ssm get-parameter \
              --name "/openai/api_key" \
              --with-decryption \
              --query 'Parameter.Value' \
              --output text 2>/dev/null
          )

          if [ $? -ne 0 ] || [ -z "$OPENAI_API_KEY_VALUE" ]; then
            echo "Failed to retrieve OPENAI_API_KEY from SSM Parameter Store"
            exit 1
          fi

          export OPENAI_API_KEY="$OPENAI_API_KEY_VALUE"
        fi

        if [ -z "$GEMINI_API_KEY" ]; then
          echo "GEMINI_API_KEY is not set. Retrieving from AWS SSM Parameter Store..."

          GEMINI_API_KEY_VALUE=$(
            AWS_PROFILE=davidroussov \
            aws ssm get-parameter \
              --name "/google/gemini/api_key" \
              --query 'Parameter.Value' \
              --output text 2>/dev/null
          )

          if [ $? -ne 0 ] || [ -z "$GEMINI_API_KEY_VALUE" ]; then
            echo "Failed to retrieve GEMINI_API_KEY from SSM Parameter Store"
            exit 1
          fi

          export GEMINI_API_KEY="$GEMINI_API_KEY_VALUE"
        fi

        if [ -z "$KAGI_API_KEY" ]; then
          echo "KAGI_API_KEY is not set. Retrieving from AWS SSM Parameter Store..."

          KAGI_API_KEY_VALUE=$(
            AWS_PROFILE=davidroussov \
            aws ssm get-parameter \
              --name "/kagi/api_key" \
              --with-decryption \
              --query 'Parameter.Value' \
              --output text 2>/dev/null
          )

          if [ $? -ne 0 ] || [ -z "$KAGI_API_KEY_VALUE" ]; then
            echo "Failed to retrieve KAGI_API_KEY from SSM Parameter Store"
            exit 1
          fi

          export KAGI_API_KEY="$KAGI_API_KEY_VALUE"
        fi

        # Oh My Zsh installation
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
          echo "Installing Oh My Zsh..."
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
          rm -f "$HOME/.zshrc"
          ln -s "$HOME/@/dot/.zshrc" "$HOME/.zshrc"

          git clone https://github.com/jeffreytse/zsh-vi-mode "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
        fi

        # Python crap
        if [ ! -d "$HOME/.venv" ]; then
          echo "Installing python packages"
          python -m venv ~/.venv
          source ~/.venv/bin/activate
          pip install llm
          llm install llm-gemini
          llm install llm-anthropic
          deactivate
        fi

        # vim
        if [ ! -d "$HOME/.vim/autoload" ]; then
          curl -fLo ~/.vim/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        fi

        zsh
      '';
    };
  };
}

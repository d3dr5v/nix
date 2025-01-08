{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    pkgs.git
    pkgs.neovim
    pkgs.tree
    pkgs.terraform
    pkgs.zoxide
    pkgs.jq
    pkgs.tmux
    pkgs.moreutils
    pkgs.timewarrior
    pkgs.mpv
    pkgs.awscli
  ];

  shellHook = ''
		export NIX_SHELL=true

		cd /Users/.david/

    alias gst="git status"
    alias gc="git commit"
    alias gp="git push"
    alias gd="git diff"

		alias ll='ls -lh'
		alias lll='ls -lh --color=auto'
		alias la='ls -lha'
		alias lla='ls -lAh --color=auto'
		alias lsd='ls -d */'
		alias lt='ls -lt'
		alias lth='ls -lht'
		alias lar='ls -larth'
		alias l1='ls -1A'
		alias lh='ls -lh --si'
		alias lr='ls -R'
		alias lc='ls --color=auto'
		alias lg='ls -lh --group-directories-first --color=auto'

    function define() {
      ~/chatgpt "Define $1"
    }

    function c() {
        awk "BEGIN { print $1 }"
    }




		if [ -z "$OPENAI_API_KEY" ]; then
			echo "OPENAI_API_KEY is not set. Retrieving from AWS Secrets Manager..."

			SECRET_VALUE=$(AWS_PROFILE=davidroussov aws secretsmanager get-secret-value --secret-id "openai.api_key" --query 'SecretString' --output text 2>/dev/null)

			if [ $? -ne 0 ]; then
				exit 1
			fi

			export OPENAI_API_KEY="$SECRET_VALUE"
		fi




    eval "$(zoxide init zsh)"

  '';
}

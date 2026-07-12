{
  description = "Development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/ace249efcbdfbd4c53aa9529251ab848fe68c5e2";

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        supabase-cli
      ];
    };
  };
}

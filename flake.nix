{
  description = "dangreco/mc environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {

          pkgs,
          ...
        }:
        {
          devShells.default =
            let
              __zed = pkgs.writeTextFile {
                name = "__zed";
                text = builtins.toJSON {
                  lsp.tofu-ls.binary = {
                    path = "${pkgs.tofu-ls}/bin/tofu-ls";
                    arguments = [ "serve" ];
                  };
                };
                destination = "/settings.json";
              };
            in
            pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                nil
                nixd
                nixfmt

                jq
                git
                act
                pinact
                moreutils
                netcat-gnu

                opentofu
                tofu-ls
                ansible

                sops
                age
                go-task
              ];

              shellHook = ''
                rm -rf .zed
                mkdir -p .zed
                cp ${__zed}/settings.json .zed/settings.json
              '';
            };
        };
    };
}

{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          devshells = {
            go = {
              packages = [
                pkgs.bashInteractive
                pkgs.go_1_25
                pkgs.gofumpt
                pkgs.golangci-lint
                pkgs.gomodifytags
                pkgs.protoc-gen-go-grpc
                pkgs.gotests
                pkgs.gotestsum
                pkgs.protoc-gen-go
                pkgs.iferr
                pkgs.impl
                pkgs.mockgen
                pkgs.reftools
                pkgs.richgo
                pkgs.buf
                pkgs.delve
                pkgs.golines
                pkgs.gotest
                pkgs.gopls
                pkgs.govulncheck
                pkgs.air
              ];
            };
          };

          packages.gophercon-demo = pkgs.buildGoModule {
            pname = "gophercon-demo";
            version = "0.0.1";
            src = ./.;
            vendorHash = "sha256-6neJC1dsav4gYyl02Ddi/MSK5Hbr3ActLePjMykApXg=";
            buildInputs = [
              pkgs.rdkafka
              pkgs.cyrus_sasl
            ];
          };

          packages.gophercon-demo-image = pkgs.dockerTools.buildLayeredImage {
            name = "gophercon-demo";
            tag = "0.0.1";

            contents = [
              self'.packages.gophercon-demo
            ];

            config = {
              Cmd = [ "/bin/gophercon-demo" ];
            };
          };
        };
    };
}

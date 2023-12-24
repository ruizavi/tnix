{
  description = "A Nix-flake-based Node.js development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [
      (final: prev: rec {
        bunjs = prev.bun;
        openssl = prev.openssl;
        prisma = prev.nodePackages.prisma;
      })
    ];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [node2nix bunjs openssl prisma];
      };

      shellHook = with pkgs; ''
        export PRISMA_SCHEMA_ENGINE_BINARY="${prisma-engines}/bin/schema-engine"
        export PRISMA_QUERY_ENGINE_BINARY="${prisma-engines}/bin/query-engine"
        export PRISMA_QUERY_ENGINE_LIBRARY="${prisma-engines}/lib/libquery_engine.node"
        export PRISMA_INTROSPECTION_ENGINE_BINARY="${prisma-engines}/bin/introspection-engine"
        export PRISMA_FMT_BINARY="${prisma-engines}/bin/prisma-fmt"
      '';
    });
  };
}

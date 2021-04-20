{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # poetry.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer.url = "github:teto/mptcpanalyzer";
  };

  outputs = { self, nixpkgs, flake-utils }: let
  in flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      mptcpanalyzer = pkgs.callPackage ./contrib/default.nix {};
    in rec {

      packages = {
        # mptcpanalyzer = mptcpanalyzer;

        # mptcp-pm = 

      };
    }) // {

      nixosModules = [
        (import ./modules/mptcp)
      ];

      overlay = final: prev: {
        linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
          kernelPatches = final.linux_4_19.kernelPatches;
        };

        iproute-mptcp = final.callPackage ./pkgs/iproute-mptcp {};
      };


    };
}

{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # poetry.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer-python.url = "github:teto/mptcpanalyzer";
    # mptcpanalyzer-haskell.url = "github:teto/quantum";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }: let
  in flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
        config = { allowUnfree = true; allowBroken = true; };
      };

      # mptcpanalyzer-python = pkgs.callPackage ./contrib/default.nix {};
    in rec {

      packages = inputs.mptcpanalyzer-python.packages."${system}" // {
        # TODO
        # mptcpanalyzer = mptcpanalyzer;
        # mptcp-pm =
        inherit (pkgs) linux_mptcp_95;
      };

      defaultPackage = inputs.mptcpanalyzer-python.packages."${system}".mptcpanalyzer;

      # checks = 
    })
    // {

      nixosModules = {
        mptcp = (import ./modules/mptcp);
      };

      overlay = final: prev: {
        linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
          kernelPatches = final.linux_4_19.kernelPatches;
        };

        iproute-mptcp = final.callPackage ./pkgs/iproute-mptcp {};
      };


    };
}

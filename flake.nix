{
  description = "Multipath TCP related software";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # poetry.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer-python.url = "github:teto/mptcpanalyzer";
    mptcp-pm.url = "github:teto/mptcp-pm";
    mptcpanalyzer-haskell.url = "github:teto/quantum";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }: let
  in flake-utils.lib.eachSystem ["x86_64-linux"] (system: let

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
        config = { allowUnfree = true; allowBroken = true; };
      };

    in rec {

      packages = {
        mptcpanalyzer = inputs.mptcpanalyzer-python.packages."${system}".mptcpanalyzer;
        # TODO fix
        # mptcpanalyzer = mptcpanalyzer-haskell
        # mptcp-pm = inputs.mptcp-pm.packages."${system}".mptcp-pm;
        mptcptrace = pkgs.callPackage ./pkgs/mptcptrace {};
        mptcpplot = pkgs.callPackage ./pkgs/mptcpplot {};
        iproute-mptcp = pkgs.callPackage ./pkgs/iproute-mptcp {};

        mptcpnumerics = pkgs.python3Packages.callPackage ./mptcpnumerics.nix {};


        inherit (pkgs) linux_mptcp_95;
      };

      defaultPackage = inputs.mptcpanalyzer-python.packages."${system}".mptcpanalyzer;

    })
    // {

      nixosModules = {
        mptcp = (import ./modules/mptcp);
      };

      overlay = final: prev: {
        linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
          kernelPatches = final.linux_4_19.kernelPatches;
        };

        linux_net_next = {
        };
      };


    };
}

{
  description = "Multipath TCP related software";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer-python.url = "github:teto/mptcpanalyzer";
    mptcp-pm.url = "github:teto/mptcp-pm";
    mptcpanalyzer-haskell.url = "github:teto/quantum";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
        config = { allowUnfree = true; allowBroken = true; };
      };

    in rec {

      packages = {
        mptcpanalyzer = self.inputs.mptcpanalyzer-python.packages.${system}.mptcpanalyzer;
        # TODO fix
        # mptcpanalyzer = mptcpanalyzer-haskell
        # mptcp-pm = inputs.mptcp-pm.packages."${system}".mptcp-pm;
        iproute-mptcp = pkgs.callPackage ./pkgs/iproute-mptcp {};


        inherit (pkgs) linux_mptcp_95 mptcpd mptcpnumerics mptcpplot mptcptrace;
      };

      defaultPackage = self.inputs.mptcpanalyzer-python.packages.${system}.mptcpanalyzer;

    })
    // {

      nixosModules = {
        mptcp = (import ./modules/mptcp);
      };

      overlay = final: prev: {
        linux_mptcp_96 = final.callPackage ./pkgs/linux-mptcp/96.nix {
          # kernelPatches = final.linux_4_19.kernelPatches;
        };
        mptcpd = final.callPackage ./pkgs/mptcpd {};
        linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
          kernelPatches = final.linux_4_19.kernelPatches;
        };
        mptcptrace = final.callPackage ./pkgs/mptcptrace {};
        mptcpplot = final.callPackage ./pkgs/mptcpplot {};

        mptcpnumerics = final.python3Packages.callPackage ./mptcpnumerics.nix {};
      };

    };
}

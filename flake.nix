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


        inherit (pkgs) linux_mptcp_95 mptcpd mptcpnumerics mptcpplot mptcptrace iperf3-mptcp;
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

        iperf3-mptcp = final.iperf3.overrideAttrs(oa: {

          src = final.fetchFromGitHub {

            owner = "pabeni";
            repo = "iperf";
            rev = "26b066b9d4e92442d55950689dbd9fd101b429a7";
            sha256 = "sha256-Z2i93sRVp8KgNPY58Mme3MfYx8QdhcQZ/Z95TWl6nMc=";

          };
        });
      };

    };
}

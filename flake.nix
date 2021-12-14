{
  description = "Multipath TCP related software";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer-python.url = "github:teto/mptcpanalyzer";
    mptcp-pm.url = "github:teto/mptcp-pm";
    mptcpanalyzer-haskell.url = "github:teto/quantum";
    linux-kernel-mptcp = {
      url = "github:teto/linux/mptcp_95_enable_on_localhost";
      flake = false;
    };
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
        inherit (pkgs) linux_mptcp_95-patched linux_mptcp_95-matt;
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

        # my fork with several patches
        # one of them enables mptcp on localhost
        linux_mptcp_95-patched = final.callPackage ./pkgs/linux-mptcp/patched.nix {

          kernelPatches = [];
        };

        # doesn't seem to work, it triggers
        # Failed assertions:
        # - CONFIG_NET is not enabled!
        linux_mptcp_95-matt = (final.linux_mptcp_95.override( {
          # src = self.inputs.linux-kernel-mptcp;
          mptcpVersion = "0.96.0";
          modDirVersion = "5.1.0";

        })).overrideAttrs (oa: {
        # linux_mptcp_95-matt = prev.buildLinux (rec {
        #   version = "${modDirVersion}-mptcp_v${mptcpVersion}";
        #   # autoModules= true;

        #   extraMeta = {
        #     branch = "5.1";
        #   };

          src = final.fetchFromGitHub {
            owner = "teto";
            repo = "linux";

            rev = "4e5027564537dfc77768dfda090cfb060b090551"; # branch mptcp_95_enable_on_localhost
            sha256 = "sha256-sKgRTTmetM4EFuiKEU8mD+yJuI/PwV62HqaMSKInXvw=";
          };
          # modDirVersion 4.19.126 specified in the Nix expression is wrong, it should be: 
        });

        linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
          kernelPatches = final.linux_4_19.kernelPatches;
        };
        mptcptrace = final.callPackage ./pkgs/mptcptrace {};
        mptcpplot = final.callPackage ./pkgs/mptcpplot {};

        mptcpnumerics = final.python3Packages.callPackage ./pkgs/mptcpnumerics.nix {};

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

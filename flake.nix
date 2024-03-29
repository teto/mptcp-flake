{
  description = "Multipath TCP related software";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mptcpanalyzer-python.url = "github:teto/pymptcpanalyzer";
    mptcp-pm.url = "github:teto/mptcp-pm";
    mptcpanalyzer-haskell.url = "github:teto/mptcpanalyzer";
    linux-kernel-mptcp = {
      url = "github:teto/linux/mptcp_95_enable_on_localhost";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let

          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config = { 
              allowUnfree = true;
              allowBroken = true;
              allowAliases = false;
            };
          };

        in
        {

          packages = {
            default = self.packages.${system}.mptcpanalyzer;
            mptcpanalyzer = self.inputs.mptcpanalyzer-python.packages.${system}.mptcpanalyzer;

            # TODO fix
            # mptcpanalyzer = mptcpanalyzer-haskell
            # mptcp-pm = inputs.mptcp-pm.packages."${system}".mptcp-pm;
            iproute-mptcp = pkgs.callPackage ./pkgs/iproute-mptcp { };

            inherit (pkgs) mptcpd mptcpnumerics mptcpplot mptcptrace iperf3-mptcp linux_mptcp_96;
            inherit (pkgs) protocol;
          };
        })
    // {

      nixosModules = rec {
        default = mptcp;
        mptcp = (import ./modules/mptcp);
      };

      overlays.default = final: prev: {

        net-tools = prev.callPackage ./pkgs/net-tools { };
        patch_enable_mptcp_on_localhost = { name = "enable_on_localhost"; patch = ./pkgs/linux-mptcp/enable_on_localhost.patch; };
        mptcpd = prev.callPackage ./pkgs/mptcpd { };

        linux_mptcp_96 = final.callPackage ./pkgs/linux-mptcp/96.nix {
          # final.patch_enable_mptcp_on_localhost
          kernelPatches = [ ];
        };

        # TODO should be either updated or bound to an older nixpkgs
        # my fork with several patches
        # one of them enables mptcp on localhost
        # linux_mptcp_95-matt = (final.linux_mptcp_95.override ({
        #   # src = self.inputs.linux-kernel-mptcp;
        #   mptcpVersion = "0.95.2";
        #   modDirVersion = "5.1.0";
        # })).overrideAttrs (oa: {
        #   src = final.fetchFromGitHub {
        #     owner = "teto";
        #     repo = "linux";

        #     rev = "4e5027564537dfc77768dfda090cfb060b090551"; # branch mptcp_95_enable_on_localhost
        #     sha256 = "sha256-sKgRTTmetM4EFuiKEU8mD+yJuI/PwV62HqaMSKInXvw=";
        #   };
        #   # modDirVersion 4.19.126 specified in the Nix expression is wrong, it should be: 
        # });

        # linux_mptcp_95 = final.callPackage ./pkgs/linux-mptcp/95.nix {
        #   kernelPatches = final.linux_4_19.kernelPatches;
        # };

        linux_mptcp_net_next = final.callPackage ./pkgs/linux-net-next.nix { };

        mptcptrace = final.callPackage ./pkgs/mptcptrace { };
        mptcpplot = final.callPackage ./pkgs/mptcpplot { };

        protocol = final.python3Packages.callPackage ./pkgs/protocol { };

        mptcpnumerics = final.python3Packages.callPackage ./pkgs/mptcpnumerics.nix { };

        iperf3-mptcp = final.iperf3.overrideAttrs (oa: {

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

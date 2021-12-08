{ lib, buildPackages, fetchFromGitHub, perl, buildLinux, structuredExtraConfig ? {}, ... } @ args:
let
  mptcpVersion = "0.96";
  modDirVersion = "5.4.155";
in
buildLinux ({
  version = "${modDirVersion}-mptcp_v${mptcpVersion}";
  inherit modDirVersion;
  ignoreConfigErrors = true;

  extraMeta = {
    branch = "5.4";
    maintainers = with lib.maintainers; [ teto layus ];
  };

  src = fetchFromGitHub {
    owner = "multipath-tcp";
    repo = "mptcp";
    rev = "v${mptcpVersion}";
    sha256 = "sha256-J9UXhkI49cq83EtojLHieRtp8fT3LXTJNIqc+mUwZdM=";
  };

  structuredExtraConfig = lib.mkMerge [
    (import ./mptcp-config.nix { inherit lib; })
    structuredExtraConfig
  ];

} // args)


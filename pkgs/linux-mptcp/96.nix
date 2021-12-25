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
    rev = "4967fef261f624db592f0e511d01b1b37082c122";
    sha256 = "sha256-6O/UQhxcMrT6Xr3V5niJmVuFDy7COhgFKg60IvWle2U=";
  };

  structuredExtraConfig = lib.mkMerge [
    (import ./mptcp-config.nix { inherit lib; })
    structuredExtraConfig
  ];

} // args)


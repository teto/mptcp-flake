{ lib, buildPackages, fetchFromGitHub, perl, buildLinux, structuredExtraConfig ? {}, ... } @ args:
let
  mptcpVersion = "0.96.0";
  modDirVersion = "5.1.0";
in
buildLinux ({
  version = "${modDirVersion}-mptcp_v${mptcpVersion}";
  inherit modDirVersion;
  ignoreConfigErrors = true;

  extraMeta = {
    branch = "4.19";
    maintainers = with lib.maintainers; [ teto ];
  };

  src = fetchFromGitHub {
    owner = "teto";
    repo = "linux";

    rev = "4e5027564537dfc77768dfda090cfb060b090551"; # branch mptcp_95_enable_on_localhost
    sha256 = "sha256-sKgRTTmetM4EFuiKEU8mD+yJuI/PwV62HqaMSKInXvw=";
  };

  structuredExtraConfig = lib.mkMerge [
    (import ./mptcp-config.nix { inherit lib; })
    structuredExtraConfig
  ];

} // args)


{ linux_latest, fetchFromGitHub }:
linux_latest.overrideAttrs(oa: {

  # https://github.com/multipath-tcp/mptcp_net-next
  src = fetchFromGitHub {
    owner = "multipath-tcp";
    repo = "mptcp_net-next";
    rev = "57998fd9d1b03466ad75d601cfa585a18a4b0c6c";
    sha256 = "1wy7lkh8d1a64ihh75yq7r6hajzrwylpccxcjkzmv8np9ycdmxg6";
  };
})

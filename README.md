# mptcp-flake

A nix flake for multipath TCP software.

Contains (run `nix flake check` for an up-to-date list):
- [mptcpanalyzer]
- [mptcptrace]
- [mptcpplot]
- [mptcpd]
- [original kernel linux mptcp fork](http://multipath-tcp.org/)
- a custom fork with my patches (One-way-delays, enable MPTCP on localhost, ...)
- MPTCP net-next
- a nixos module to easily setup multipath TCP

[mptcpanalyzer]: https://github.com/teto/mptcpanalyzer
[mptcptrace]: https://bitbucket.org/bhesmans/mptcptrace
[mptcpplot]: https://github.com/nasa/multipath-tcp-tools/
[mptcpd]: https://github.com/intel/mptcpd

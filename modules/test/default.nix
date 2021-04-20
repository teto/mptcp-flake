# Test whether `networking.mptcp' works as expected.
# 1/ creates 2 multihomed VMs
# 2/ selects the redundant scheduler to ensure packets are sent on all links
# 3/ start tshark to capture on concerned interfaces while running an iperf session
# 4/ load the recorded pcap and display the interfaces that received MPTCP traffic
# 5/ Use shell-foo to make sure it's equal to the number of interfaces of the host
import ../make-test-python.nix ({ pkgs, lib, ...} :
let
  vlans = [ 1 0 ];

  default-config = {

    services.xserver.enable = false;

    virtualisation.memorySize = 512;

    programs.wireshark.enable = true;

    networking = {
      networkmanager.enable = true;
      useDHCP = false;
      interfaces = {
        eth0 = { useDHCP = false; };
        eth1 = { useDHCP = false; };
      };
    };

    networking.dhcpcd.enable = false;  # true by default

    environment.systemPackages = with pkgs; [
      iperf3
    ];

    networking.mptcp = {
      enable = true;
      debug = true;
      # we choose the redundant scheduler to ensure traffic is sent on all interfaces
      scheduler = "redundant";
    };

    # create 2 networks
    virtualisation.vlans = vlans;

    # get rid of the default user interface that mess up interface assignment
    virtualisation.qemu.networkingOptions = [ ];

  };
in
{
  name = "networking-mptcp";
  meta = with lib.maintainers; {
    maintainers = [ teto ];
  };

  nodes = {
    client = default-config;

    server = { ... }:
      default-config // {
        services.iperf3 = {
          enable = true;
          openFirewall = true;
        };
      };
  };

  # TODO check log
  # machine.wait_for_text("Home")  # The desktop
  # machine.screenshot("wizard12")
  # wait_for_file
  # machine.wait_for_x()

  testScript =
    ''
      start_all()

      log.log("Client info")
      print(client.execute("ip addr"))
      print(server.execute("ip addr"))


      client.wait_until_succeeds("dmesg | grep MPTCP")
      server.wait_until_succeeds("dmesg | grep MPTCP")

      server.wait_for_unit("network.target")

      # Test ICMP.
      client.succeed("ping -c 1 server >&2")
      server.succeed("ping -c 1 client >&2")

      server.wait_for_unit("iperf3.service")

      client.succeed("tshark -i eth0 -i eth1 -a duration:30 -f 'tcp' -w test.pcap &")
      # source -> target_dir (optional)
      # client.copy_from_vm("test.pcap")

      # iperf test: sends -n <bytes> or -t <seconds>, -b limits bitrate
      client.execute("iperf -c server -t 5 -b 1KiB")

      client.wait_until_succeeds(
          "tshark -2 -R 'mptcp' -r test.pcap -Tfields -e frame.interface_id > packet_interfaces.txt"
      )
      client.copy_from_vm("packet_interfaces.txt")
      (retcode, output) = client.execute("head packet_interfaces.txt")
      if retcode != 0:
          raise Exception("tshark could not load from test.pcap")

      output = client.succeed("cat packet_interfaces.txt|uniq|wc -l")
      log.log(output)
      if int(output) == ${toString (builtins.length vlans)}:
          print(output)
          raise Exception("Not all interfaces have been used to send MPTCP traffic")

      print(client.succeed("ip route show table eth0"))
      print("Client table eth1\n")
      print(client.succeed("ip route show table eth1"))
      print("\n")
      print("Server table eth0\n")
      print(server.execute("ip route show table eth0"))
      print("Server table eth1")
      print(server.execute("ip route show table eth1"))
    '';
})


- HOST PREREQUISITES
====
	- install/check lxd, openvswitch, dnsmasq, lvm
	- get ethernet port for vswitch
		- PERF : get block device for storage pool

- OpenVswitch
====
	- create vswitch
	- create dnsmasq virtual port
	- add ethernet port to vswitch
		- VLAN : configure fakebridge(s)

- dnsmasq
====
	- configure DHCP, DNS, TFTP, iPXE
		- VLAN : configure DHCP, DNS, TFTP, iPXE

- LXD
====
	- create profile
		- PERF : attach profile to dedicated storage pool
		- VLAN : attach profile to fakebridge for VLAN
	- create container

- container
====
	- install samba
	- configure unsecure anonymous writable public share
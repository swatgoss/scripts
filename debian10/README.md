- RetroHOST : PREREQUISITES
	- install/check lxd, openvswitch, dnsmasq, lvm
	- get ethernet port for vswitch
		- PERF : get block device for storage pool

- RetroHOST : OpenVswitch
	- create vswitch
	- create dnsmasq virtual port
	- add ethernet port to vswitch
		- VLAN : configure fakebridge(s)

- RetroHOST : dnsmasq
	- configure DHCP, DNS, TFTP, iPXE
		- VLAN : configure DHCP, DNS, TFTP, iPXE

- RetroHOST : LXD
	- create a container profile
		- PERF : attach profile to dedicated storage pool
		- VLAN : attach profile to fakebridge for VLAN
	- create retronas container
		- create iPXE-ISOBOOT container

- container : RetroNAS
	- install samba
	- configure unsecure anonymous writable public share

- container : iPXE-ISOBOOT
	- install nginx
	- configure http ISO hosting
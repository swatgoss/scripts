- RetroHOST : PREREQUISITES
	- install/check snapd, openvswitch-switch, dnsmasq, lvm2
	- get ethernet port for vswitch
		- PERF : get block device for storage pool

- RetroHOST : OpenVswitch
	- create vswitch
	`ovs-vsctl add-br LXDvswitch0`
	- create dnsmasq virtual port
	`ovs-vsctl add-port LXDvswitch0 LXDdnsmasq0 -- set interface LXDdnsmasq0 type=internal`
	- add ethernet port to vswitch
	`ovs-vsctl add-port LXDvswitch0 enp0s8`
		- VLAN : configure fakebridge(s)

- RetroHOST : dnsmasq
	- configure DHCP, DNS, TFTP, iPXE
		- VLAN : configure DHCP, DNS, TFTP, iPXE

- RetroHOST : LXD
	- create a container profile
	`lxc profile create conteneurs`
		- PERF : attach profile to dedicated storage pool
	`lxc profile device add conteneurs root disk path=/ pool=LXDstoragepool0`

	- create retronas container
	`lxc init images:debian/10 RetroNAS -p conteneurs`
	- attach container to vswitch (or attach to fakebridge for VLAN)
	`lxc config device add RetroNAS eth0 nic nictype=bridged parent=LXDvswitch0 host_name=RetroNAS`

	- create ISOBoot (for iPXE clients) container
	`lxc init images:debian/10 ISOBoot -p conteneurs`
	- attach container to vswitch (or attach to fakebridge for VLAN)
	`lxc config device add ISOBoot eth0 nic nictype=bridged parent=LXDvswitch0 host_name=ISOBoot`

- container : RetroNAS
	- start container
		`lxc start RetroNAS`
	- install samba
		`lxc exec RetroNAS -- apt install -y samba`
	- configure unsecure anonymous writable public share
		`lxc exec RetroNAS -- vim /etc/samba/smb.conf`

- container : iPXE-ISOBOOT
	- install nginx
	- configure http ISO hosting

#!/bin/sh
sudo bluez-simple-agent hci0 F0:65:DD:73:58:3E remove
sudo bluez-simple-agent hci0 F0:65:DD:73:58:3E
sudo bluez-test-device trusted F0:65:DD:73:58:3E yes
sudo bluez-test-input connect F0:65:DD:73:58:3E

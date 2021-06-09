# login-server

## Purpose

This project is to create a docker container for a simple ssh host, controlled by systemd.

The ssh host is setup to act as a jump host or for tunneling.

Authentication is by default only possible by public key.

## How to use

#### prerequisites

- systemd
- docker
- docker-compose
- make

#### Setup

To setup the system, clone the repository to a folder and type `sudo make install`.

In the top of the makefile it is possible to set another name for the application and change the ssh port (default `login-server` and `21986`).

To uninstall the application type `sudo make uninstall` inside the cloned folder.

Type `sudo make update` to reinstall the application (keys and log persists).

Type `sudo make clean` to remove installation artifacts. (also done by `make uninstall`)

#### How to connect

Append public keys to `/var/login-server/authorized_keys`.

To create tunnel: `ssh -Np 21986 login@<host>`.

To jump: `ssh -J login@<host>:21986 <destination_user>@<destination_host>`.

To enter docker conatiner type `docker exec -it login-server bash`.
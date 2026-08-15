packer {
  required_version = ">= 1.7.0"
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "virtualbox-iso" "slackware" {
  vm_name    = "slackware-15.0"
  memory     = 1024
  cpus       = 2
  disk_size  = 20480

  iso_url         = "./slackware64-15.0/slackware-15.0-install-dvd.iso"
  iso_checksum    = "sha256:f795ef602707bcd0c2e615e88b307f71a18039ee54c89a0109588500258991c2"

  boot_wait = "10s"
  boot_command = [
    "<wait10s>",
    "huge.s<enter>",
    "<wait180s>",
    "root<enter>",
    "<wait5s>",
    "mount /dev/fd0 /mnt 2>/dev/null; sh /mnt/install.sh<enter>"
  ]

  floppy_files = ["${path.root}/scripts/install.sh"]

  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "60m"

  shutdown_command = "sudo shutdown -h now"

  headless              = true
  guest_additions_mode  = "disable"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--boot1", "disk"],
    ["modifyvm", "{{.Name}}", "--boot2", "dvd"],
  ]
}

build {
  sources = ["source.virtualbox-iso.slackware"]

  post-processor "vagrant" {
    output = "slackware-15.0.box"
  }
}

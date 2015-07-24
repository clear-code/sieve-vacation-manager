# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "chef/centos-6.5"

  config.vm.network "private_network", ip: "192.168.33.23"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline <<-SHELL
  #   sudo apt-get install apache2
  # SHELL

  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = ["vendor/cookbooks", "cookbooks"]
    chef.data_bags_path = "data-bags"
    chef.add_recipe "apache2"
    chef.add_recipe "postfix"
    chef.add_recipe "dovecot"
    chef.add_recipe "users"
    chef.add_recipe "mariadb"

    chef.json = {
      "apache2" => {},
      "postfix" => {
        "main" => {
          "inet_interfaces" => "all",
          "inet_protocols" => "ipv4",
          "mynetworks_style" => "subnet",
          "mynetworks" => "192.168.33.0/24",
          "alias_maps" => "hash:/etc/aliases",
          "alias_database" => "hash:/etc/aliases",
          # for virtual users
          # http://wiki2.dovecot.org/HowTo/VirtualUserFlatFilesPostfix
          "virtual_mailbox_domains" => "example.co.jp, example.com, example.net",
          "virtual_mailbox_base" => "/var/vmail",
          "virtual_minimum_uid" => "100",
          "virtual_uid_maps" => "static:5000",
          "virtual_gid_maps" => "static:5000",
          "virtual_transport" => "dovecot",
          # SMTP Auth
          "smtpd_sasl_type" => "dovecot",
          "smtpd_sasl_path" => "private/auth",
          "smtpd_sasl_auth_enable" => "yes",
          "smtpd_recipient_restrictions" => "permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination",
          # TLS
          "smtp_use_tls" => "no",
          "smtpd_use_tls" => "no",
          # Dovecot LDA
          "mailbox_command" => '/usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"',
        },
        "master" => {
          "pipe" => {
            "dovecot" => {
              "flags" => "DRhu",
              "user" => "vmail:vmail",
              "argv" => "/usr/libexec/dovecot/dovecot-lda -f ${sender} -a ${recipient} -d ${user}@${nexthop}",
            }
          }
        }
      },
      "dovecot" => {
        "conf" => {
          "postmaster_address" => "postmaster@example.com",
          "disable_plaintext_auth" => "no",
          "mail_location" => "maildir:/var/vmail/%d/%n/Maildir",
        },
        "protocols" => {
          "imap" => {},
          "pop3" => {},
          "sieve" => {},
          "lda" => {
            "mail_plugins" => ["$mail_plugins", "sieve"]
          },
        },
        "namespaces" => [
          {
            "type" => "private",
            "separator" => "/",
            "prefix" => "",
            "hidden" => "no",
            "inbox" => "yes",
          },
          {
            "type" => "public",
            "separator" => "/",
            "prefix" => "Public/",
            "location" => "maildir:/var/vmail/public:LAYOUT=fs:INDEX=/var/vmail/vindex/public",
            "list" => "yes",
            "subscriptions" => "no",
          },
        ],
        "services" => {
          "auth" => {
            "listeners" => [
              {
                "unix:auth-userdb" => {
                  "mode" => "0600",
                  "user" => "vmail",
                  "group" => "vmail",
                },
                "unix:/var/spool/postfix/private/auth" => {
                  "mode" => "0666",
                  "user" => "postfix",
                  "group" => "postfix",
                }
              },
            ],
          },
          "managesieve-login" => {
            "listeners" => [
              {
                "inet:sieve" => {
                  "port" => "4190",
                },
              },
            ],
          },
        },
        "auth" => {
          "system" => {},
          "passwdfile" => {
            "passdb" => {
              "driver" => "passwd-file",
              "args" => "scheme=CRYPT username_format=%u /etc/dovecot/users"
            },
            "userdb" => {
              "driver" => "passwd-file",
              "args" => "username_format=%u /etc/dovecot/users"
            }
          }
        },
        "plugins" => {
          "sieve" => {
            "sieve" => "~/.dovecot.sieve",
            "sieve_dir" => "~/sieve",
          }
        },
        "virtual_users" => [
          {
            "name" => "alice",
            "domain" => "example.com",
          },
          {
            "name" => "bob",
            "domain" => "example.com",
          },
          {
            "name" => "charlie",
            "domain" => "example.com",
          },
          {
            "name" => "yamada",
            "domain" => "example.co.jp",
          },
          {
            "name" => "tanaka",
            "domain" => "example.co.jp",
          },
          {
            "name" => "suzuki",
            "domain" => "example.co.jp",
          },
          {
            "name" => "don",
            "domain" => "example.net",
          },
          {
            "name" => "eric",
            "domain" => "example.net",
          },
          {
            "name" => "fred",
            "domain" => "example.net",
          },
        ]
      },
    }
  end
end

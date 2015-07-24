# How to develop

Vagrant をインストールする。

* http://www.vagrantup.com/downloads

Chef DK をインストールする。

* http://downloads.chef.io/chef-dk/

以下のコマンドを実行する。

```
$ bundle install --path vendor/bundle
$ berks vendor vendor/cookbooks
$ vagrant up
```

以下のコマンドで仮想マシンに vagrant ユーザーで SSH でログインできる。
vagrant ユーザーはパスワードなしで sudo 可能。

```
$ vagrant ssh
```

この環境では以下のことができる。

* Postfix + Dovecot でメールを送受信できる。
* SMTP, POP3, IMAP, Sieve
* 認証: plain, login
  * 例えば user:alice@example.com, pass:test でログインできる(全員パスワードは test)
* /var/vmail/<domain>/<user>/.dovecot.sieve に sieve スクリプトを置けば sieve が動く
* SSL は無効
* SCL からインストールした MariaDB
  * `mysql_secure_installation` コマンドは実行済み
  * MariaDB の root ユーザーのパスワードは root
  * アプリケーションで使う DB は自分で作る

プライベートネットワークとして 192.168.33.23 を作っているので、自分の
マシンから直接 SMTP/POP3/IMAP でアクセスできる。

# インストール方法

## 専用のユーザーの準備

以下のコマンドで sieve-vacation-manager ユーザーを作成する

```bash
$ sudo groupadd --system sieve-vacation-manager
$ sudo useradd --system -c "Sieve vacation manager" -m -g sieve-vacation-manager sieve-vacation-manager
$ sudo chmod 0705 /home/sieve-vacation-manager/
```

## パッケージの展開

/tmp/sieve-vacation-manager-0.0.1.tar.gz にパッケージが置かれているものとして、
以下のコマンドでパッケージを展開する。

```bash
$ cd /home/sieve-vacation-manager
$ sudo -u sieve-vacation-manager -H tar xvfz /tmp/sieve-vacation-manager-0.0.1.tar.gz
$ sudo -u sieve-vacation-manager -H mv sieve-vacation-manager-0.0.1 sieve-vacation-manager
```

## 設定ファイルの編集

### DB設定

configフォルダの中にある `user.sql.sample` を `user.sql` に、
`settings.yml.sample` を `settings.yml` にそれぞれコピーする。

```bash
$ cd /home/sieve-vacation-manager/sieve-vacation-manager/config
$ sudo -u sieve-vacation-manager -H cp user.sql.sample user.sql
$ sudo -u sieve-vacation-manager -H cp settings.yml.sample settings.yml
```

user.sql内のDBユーザー、パスワードを適切に変更する。また、同ディレクトリ内の
database.yml のDBユーザー、パスワードを同じものに変更する。

### アプリケーション設定

settings.yml についても適切に編集する。主に以下の設定が必要となる。

  * managesieve-server
    * host: 使用するManageSieveサーバのアドレス
  * internal-domains: 社内とみなすドメインのリスト

### UIメッセージの設定

UI上の一部の文字列は、messages.yml を編集することで変更することができる。
必要に応じて編集する。

### Apacheの設定

tool/httpd_addtional_settings.conf を適切に編集する。このファイルは後述のイン
ストールスクリプトで/etc/httpd/conf.d/virtualhost.confにコピーされる。

### プロキシの設定

後述のインストールスクリプトでは、必要なファイルをインターネットからダウンロー
ドしてインストールする可能性がある。必要に応じてプロキシの設定を行う。


## インストールの実行

パッケージを展開したディレクトリ内の tool/install.sh を root権限で実行する。

```bash
$ cd /home/sieve-vacation-manager/sieve-vacation-manager/tool
$ sudo ./install.sh
```

## DBの設定

正常に `install.sh` が終了していれば、設定は完了している。

個別に設定する必要がある場合は `tool/prepare_mariadb55-server.sh` を実行する。

```bash
$ ./tool/prepare_mariadb55-server.sh
```

`MySQL setup Completed!!` と表示されれば設定が完了している。

## Passengerの設定

正常に `install.sh` が終了していれば、設定は完了している。

個別に設定する必要がある場合は `tool/put_virtualhost_conf.sh` を実行する。

```bash
$ ./tool/prepare_mariadb55-server.sh
```

`"httpd setup Completed!!"` と表示されれば設定が完了している。

## httpdを再起動

正常に `install.sh` が終了していれば、設定は完了している。

個別に設定する必要がある場合は `tool/finalize.sh` を実行する。

```bash
$ ./tool/finalize.sh
```

## 動作確認

ブラウザで、同サーバのトップページにアクセスする。

例) WebサーバのIPアドレスが `192.168.33.24` の場合

```bash
$ firefox http://192.168.33.24/
```

正しくセットアップされている場合は、ログイン画面が表示される。
ManageSieveのアカウントでログインすることができる。
UIで不在通知設定を行い、画面上部の「適用」ボタンを押すと、メールサーバにSieve
フィルタが設置される。

英語で表示したい場合は、ブラウザの言語設定で英語(en)を最優先言語とする。

### トラブルシューティング

* ログイン後、Internal Server Errorと表示される
  * 多くの場合、DB設定やManageSieveサーバの指定に問題があるので、設定を見直す。
  * /var/log/httpd/error_log を参照して原因を調査する。
    原因を特定できない場合は同ログを開発者に送付する

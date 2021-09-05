# aws-auto-constructor

<br>

## 説明

AWS の環境構築を自動化しています。

<br>

### ■ 作成されるもの

- ALB (ロードバランサー)
- EC2 (踏み台サーバ = bastion)
- EC2 (本番サーバ)
- RDS (データベース)

<br>

### ■ 出力

- EC2 の秘密鍵 (`./dist/********.pem`)

<br>

### ■ デフォルトのセキュリティ設定

| リソース     | 解放ポート | アクセス元                                       |
| ------------ | ---------- | ------------------------------------------------ |
| ALB          | 80         | `0.0.0.0/0`                                      |
|              | 443        | `0.0.0.0/0`                                      |
| EC2(bastion) | 22         | `TF_VAR_bastion_ssh_permitted_cidr`で指定した IP |
| EC2(prod)    | 22         | EC2(bastion)                                     |
|              | 80         | ALB                                              |
| RDS          | 3306       | EC2(prod)                                        |

<br>

### ■ 補足

- EC2(本番)は作りたいサーバ数の分だけ`./main.tf`の`local.ec2.instances`の配列を追加してください。
- 一応`.env`で`TF_VAR_bastion_ssh_permitted_cidr=0.0.0.0/0`でどこからでも SSH 接続できるが非推奨。
- データベースは多段 SSH 経由でアクセスしてください。(ローカルの DB ツール使用の場合、`~/.ssh/config`でポートフォワーディング設定の上で SSH 接続を確立すると使用可能。)

<br>

## 使用方法

### ■ .env の設定値

| 変数名                            | 変数内容                                 |
| --------------------------------- | ---------------------------------------- |
| AWS_ACCESS_KEY                    | AWS アクセスキー                         |
| AWS_SECRET_ACCESS_KEY             | AWS シークレットアクセスキー             |
| AWS_DEFAULT_REGION                | AWS デフォルトリージョン                 |
| AWS_S3_BUCKET                     | tfstate ファイルを保存する S3 バケット名 |
| AWS_S3_KEY                        | tfstate のファイル名                     |
| TF_VAR_bastion_ssh_permitted_cidr | 踏み台サーバにログインできる IP          |
| TF_VAR_db_user                    | RDS のマスターユーザ名                   |
| TF_VAR_db_password                | RDS のマスターパスワード                 |

<br>

### ■ 初期化

```bash
$ make init
```

<br>

### ■ 実行予定内容の確認

```bash
$ make plan
```

<br>

### ■ 環境構築実行

```bash
$ make apply
```

<br>

### ■ 環境をすべて破壊

```bash
$ make destroy
```

<br>

## SSH 接続の設定

### ■ ssh_config (~/.ssh/config)

Ubuntu で EC2 インスタンス起動していることを想定しています。  
以下を追記してください。

```
Host bastion-server
    HostName ***.***.***.***
    User ubuntu
    IdentityFile ~/.ssh/my-instance/bastion.pem

Host server01
    HostName 10.0.20.***
    User ubuntu
    IdentityFile ~/.ssh/my-instance/server01.pem
    ProxyCommand ssh -W %h:%p bastion-server

Host server02
    HostName 10.0.21.***
    User ubuntu
    IdentityFile ~/.ssh/my-instance/server02.pem
    ProxyCommand ssh -W %h:%p bastion-server
```

<br>

### ■ サーバーへログイン

```bash
$ ssh server01
$ ssh server02
```

<br>

### ■ コマンド 1 発で EC2 の環境構築実行

```bash
$ SERVERS="server01 server02"; for i in ${SERVERS}; do ssh $i "sudo apt-get update -y && sudo apt-get install -y nginx mysql-client"; done
```

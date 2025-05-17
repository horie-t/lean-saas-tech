# Fargateを使用したEKSクラスタ

このTerraform設定は、us-west-2リージョンでAWS Fargateを使用してAmazon EKS（Elastic Kubernetes Service）クラスタを作成します。

## アーキテクチャ

このインフラストラクチャには以下が含まれます：

- 3つのアベイラビリティゾーンにまたがるパブリックサブネットとプライベートサブネットを持つVPC
- Fargate上で実行されるEKSクラスタ（サーバーレス）
- EKSクラスタとFargateプロファイル用のIAMロールとポリシー
- EKSクラスタ用のセキュリティグループ
- Helmプロバイダを使用したKubernetesアプリケーションのデプロイと管理機能
- Helmチャートを使用したArgoCDのインストールと設定

## 前提条件

- [Terraform](https://www.terraform.io/downloads.html)（バージョン >= 1.0.0）
- 適切な認証情報で設定された[AWS CLI](https://aws.amazon.com/cli/)
- Kubernetesクラスタと対話するための[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## 使用方法

1. Terraform設定を初期化します：

```bash
terraform init
```

2. 計画された変更を確認します：

```bash
terraform plan
```

3. 設定を適用します：

```bash
terraform apply
```

4. クラスタが作成された後、kubectlを設定してクラスタに接続します：

```bash
aws eks update-kubeconfig --region us-west-2 --name lean-saas-eks-cluster
```

5. 接続を確認します：

```bash
kubectl get nodes
```

## 変数

| 名前 | 説明 | デフォルト値 |
|------|-------------|---------|
| cluster_name | EKSクラスタの名前 | lean-saas-eks-cluster |
| cluster_version | EKSクラスタに使用するKubernetesバージョン | 1.24 |
| region | EKSクラスタをデプロイするAWSリージョン | us-west-2 |

変数の完全なリストについては、`variables.tf`ファイルを参照してください。

## 出力

| 名前 | 説明 |
|------|-------------|
| cluster_endpoint | EKSコントロールプレーンのエンドポイント |
| cluster_id | EKSクラスタID |
| configure_kubectl | kubectlを設定するためのコマンド |

出力の完全なリストについては、`outputs.tf`ファイルを参照してください。

## クリーンアップ

作成したリソースを破棄するには：

```bash
terraform destroy
```

## ArgoCD

このTerraform設定には、Helmチャートを使用したArgoCDのインストールが含まれています。ArgoCDは、Kubernetesのための宣言型GitOpsの継続的デリバリーツールです。

### ArgoCDへのアクセス

ArgoCDがデプロイされた後、以下のコマンドを使用してArgoCDサーバーのURLを取得できます：

```bash
terraform output argocd_server_url_command
```

表示されたコマンドを実行して、ArgoCDサーバーのURLを取得します。

### 初期管理者パスワードの取得

ArgoCDの初期管理者パスワードを取得するには、以下のコマンドを使用します：

```bash
terraform output argocd_admin_password_command
```

表示されたコマンドを実行して、初期管理者パスワードを取得します。

### ログイン

ArgoCDのWebUIにアクセスし、ユーザー名「admin」と取得したパスワードを使用してログインします。

## 注意事項

- この設定では、ポッドの実行にFargateプロファイルを使用しているため、管理するEC2インスタンスはありません。
- このクラスタは開発環境に必要な最小限のリソースで構成されています。
- 本番環境での使用には、追加のセキュリティ対策とリソース構成を検討してください。
- ArgoCDは「argocd」名前空間にデプロイされ、専用のFargateプロファイルを使用します。

# AWS Load Balancer Controller トラブルシューティングガイド

このドキュメントでは、AWS Load Balancer Controllerのインストールや実行時に発生する可能性のある問題のトラブルシューティング方法について説明します。

## Helmリリースの失敗を調査する方法

Terraformで`terraform apply`を実行した際に以下のようなエラーが発生した場合：

```
Warning: Helm release "" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.

Error: context deadline exceeded
```

以下の手順で問題を調査することができます：

### 1. Kubernetesクラスタへの接続を確認

まず、EKSクラスタにアクセスできることを確認します：

```bash
aws eks update-kubeconfig --region us-west-2 --name lean-saas-eks-cluster
kubectl get nodes
```

### 2. Helmリリースのステータスを確認

Helmリリースのステータスを確認します：

```bash
helm list -n kube-system
```

失敗したリリースが表示されるはずです。詳細情報を取得するには：

```bash
helm status aws-load-balancer-controller -n kube-system
```

### 3. Podのステータスを確認

AWS Load Balancer Controllerのポッドのステータスを確認します：

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

ポッドが作成されている場合は、詳細情報とログを確認します：

```bash
kubectl describe pod -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### 4. Fargateプロファイルを確認

Fargateプロファイルが正しく設定されていることを確認します：

```bash
aws eks list-fargate-profiles --cluster-name lean-saas-eks-cluster --region us-west-2
```

### 5. IAMロールとポリシーを確認

AWS Load Balancer Controllerに必要なIAMロールとポリシーが正しく設定されていることを確認します：

```bash
aws iam get-role --role-name aws-load-balancer-controller
aws iam list-attached-role-policies --role-name aws-load-balancer-controller
```

### 6. Helmチャートのバージョンを確認

使用しているHelmチャートのバージョンがEKSクラスターのバージョンと互換性があることを確認します：

```bash
helm repo update
helm search repo aws-load-balancer-controller
```

最新のチャートバージョンを使用することを検討してください。

### 7. リソース制約を確認

Fargateプロファイルのリソース制約を確認します。AWS Load Balancer Controllerが十分なCPUとメモリリソースを持っていることを確認してください。

### 8. タイムアウト設定を調整

Helmリリースのタイムアウト設定を増やすことで、インストールプロセスに十分な時間を与えることができます。Terraformの設定で`timeout`パラメータを増やしてください（例：900秒）。

### 9. 手動でHelmチャートをインストール

問題をさらに診断するために、手動でHelmチャートをインストールしてみることができます：

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=lean-saas-eks-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<IAM_ROLE_ARN> \
  --debug
```

`--debug`フラグを使用すると、詳細なインストール情報が表示されます。

## 一般的な問題と解決策

### 1. タイムアウトエラー

**問題**: `context deadline exceeded`エラーが発生する。

**解決策**: 
- Helmリリースのタイムアウト設定を増やす（例：`timeout = 900`）
- リソース制約を確認し、必要に応じて増やす
- ネットワーク接続の問題を確認する

### 2. IAMアクセス権限の問題

**問題**: AWS Load Balancer Controllerがリソースにアクセスできない。

**解決策**:
- IAMポリシーが正しく設定されていることを確認する
- サービスアカウントのアノテーションが正しいIAMロールARNを指していることを確認する

### 3. Fargateプロファイルの問題

**問題**: ポッドがスケジュールされない。

**解決策**:
- Fargateプロファイルが正しい名前空間とラベルセレクタを持っていることを確認する
- Fargateプロファイルが正常に作成されたことを確認する

### 4. バージョンの互換性の問題

**問題**: AWS Load Balancer ControllerのバージョンがEKSクラスターのバージョンと互換性がない。

**解決策**:
- EKSクラスターのバージョンと互換性のあるAWS Load Balancer Controllerのバージョンを使用する
- Helmチャートのバージョンを更新する

### 5. EC2メタデータアクセスの問題

**問題**: Fargateポッドでは、以下のようなエラーが発生することがあります：
```
{"level":"error","ts":"2025-05-17T02:23:06Z","logger":"setup","msg":"unable to initialize AWS cloud","error":"failed to get VPC ID: failed to fetch VPC ID from instance metadata: error in fetching vpc id through ec2 metadata: get mac metadata: operation error ec2imds: GetMetadata, request canceled, context deadline exceeded"}
```

**解決策**:
- AWS Load Balancer ControllerのHelmチャート設定で、VPC IDを明示的に指定します：
```terraform
set {
  name  = "vpcId"
  value = module.vpc.vpc_id
}
```
- これにより、コントローラーがEC2インスタンスメタデータからVPC IDを取得しようとするのを防ぎます
- Fargateポッドは通常のEC2インスタンスとは異なり、EC2メタデータサービスにアクセスできないため、この設定が必要です

### 6. ALB Ingressアノテーションの問題

**問題**: Helmチャートのインストール時に以下のようなエラーが発生する：
```
Error: failed parsing key "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/subnets" with value subnet-0ae2aaf802a82cf14,subnet-0335b93693cfc1737,subnet-0125d79bdefb425ec, key "subnet-0335b93693cfc1737" has no value (cannot end with ,)
```

**解決策**:
- サブネットIDのリストを結合する際に、空の値や不正な形式を防ぐために`compact`関数を使用する方法：
```terraform
set {
  name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
  value = join(",", compact(module.vpc.public_subnets))
}
```

- より堅牢な方法として、`jsonencode`と`replace`を組み合わせて使用する方法：
```terraform
set {
  name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
  value = replace(jsonencode(module.vpc.public_subnets), "/[\\[\\]\"]", "")
}
```

- `jsonencode`関数はリストをJSON文字列に変換し、`replace`関数で角括弧とダブルクォートを削除します
- この方法は、リスト内の値の形式に関係なく、常に正しくフォーマットされたカンマ区切りの文字列を生成します
- これにより、サブネットIDのリストが正しく形成され、末尾のカンマなどの問題を確実に回避できます

## 参考リソース

- [AWS Load Balancer Controller ドキュメント](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [AWS EKS ドキュメント](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Helm トラブルシューティングガイド](https://helm.sh/docs/topics/troubleshooting/)

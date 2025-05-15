# リーンなSaaSサービス開発を支える技術
## 概要
このリポジトリは、リーンなSaaSサービス開発を支える技術的な基盤を提供します。

## ディレクトリ構成

### terraform
[terraform](./terraform) ディレクトリには、AWSのEKSクラスタをFargateで構築するためのTerraformコードが含まれています。

- EKSクラスタはFargateを使用して、サーバーレスなKubernetesクラスタを提供します
- リージョンはus-west-2に設定されています
- Terraform AWS Modulesを使用して、ベストプラクティスに従った構成になっています

詳細については、[terraform/README.md](./terraform/README.md)を参照してください。

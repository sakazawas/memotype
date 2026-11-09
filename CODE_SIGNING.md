Code Signing Policy / コード署名ポリシー

English
1. Project
Memotype is an open-source repetition learning application developed and maintained by sakazawa.

2. Code Signing
Windows releases of Memotype are intended to use code signing provided through SignPath.

Free code signing provided by SignPath.io, certificate by SignPath Foundation.

3. Source Code and Build Integrity
Signed Memotype binaries must be produced from the source code maintained in the official Memotype repository.

Build scripts and continuous integration configuration used to produce release artifacts are treated as part of the project source and release process.

Release artifacts submitted for signing must correspond to an identifiable version of the source code.

4. Code Signing Roles
Memotype is currently maintained as an individual open-source project.

Current responsibilities:

Author / Committer: sakazawa
Reviewer: sakazawa
Approver: sakazawa
The developer is responsible for source-code changes, release review, and approval of code-signing requests.

If additional maintainers or contributors join the project, these roles will be updated accordingly.

5. Signing Approval
Each release submitted for code signing must be manually reviewed and approved before signing.

Only official Memotype release artifacts produced from the project's source code may be submitted for signing.

Third-party or unrelated software must not be submitted using the Memotype signing process.

6. Release Metadata
Signed release artifacts should use consistent project metadata, including:

Product name: Memotype Product 
version: corresponding to the relevant Memotype release

7. Privacy
Memotype's privacy policy is available in PRIVACY.md.

The current version of Memotype stores study data locally on the user's device and does not transmit the user's study data to developer-operated servers.

8. Security
Access to the source-code repository and code-signing service will be protected using multi-factor authentication where required for the signing process.

Code-signing credentials and signing infrastructure must not be shared or used to sign unrelated software.

日本語
1. プロジェクト
Memotype は、sakazawa が開発・保守するオープンソースの反復学習アプリケーションです。

2. コード署名
MemotypeのWindows版リリースでは、SignPathを利用したコード署名を行うことを予定しています。

無料コード署名は SignPath.io により提供され、証明書は SignPath Foundation により提供されます。

3. ソースコードとビルドの完全性
署名対象となるMemotypeのバイナリは、Memotype公式リポジトリで管理されているソースコードから生成します。

リリース成果物の生成に使用するビルドスクリプトおよびCI設定についても、プロジェクトのソースおよびリリース工程の一部として管理します。

署名申請するリリース成果物は、対応するソースコードのバージョンを識別できる状態にします。

4. コード署名に関する役割
Memotypeは現在、個人によって開発・保守されているオープンソースプロジェクトです。

現在の担当:

Author / Committer: sakazawa
Reviewer: sakazawa
Approver: sakazawa
ソースコードの変更、リリース内容の確認、コード署名申請の承認について、現在は開発者が担当します。

将来、メンテナーまたはコントリビューターが追加された場合は、必要に応じて担当を更新します。

5. 署名の承認
コード署名を申請する各リリースは、署名前に手動で内容を確認し、承認します。

プロジェクトのソースコードから生成された正式なMemotypeリリース成果物のみを署名対象とします。

第三者のソフトウェアまたはMemotypeと無関係なソフトウェアを、Memotypeの署名工程を使用して署名しません。

6. リリースメタデータ
署名対象となるリリース成果物では、以下を含むプロジェクトメタデータの一貫性を維持します。

Product name: Memotype Product 
version: 対象となるMemotypeリリースに対応するバージョン

7. プライバシー
Memotypeのプライバシーポリシーは PRIVACY.md に記載しています。

現在のMemotypeでは学習データを利用者の端末内に保存し、利用者の学習データを開発者運営のサーバーへ送信しません。

8. セキュリティ
ソースコードリポジトリおよびコード署名サービスへのアクセスについて、署名工程で要求される多要素認証を使用します。

コード署名に関する認証情報および署名環境を第三者と共有したり、Memotypeと無関係なソフトウェアの署名に使用したりしません。

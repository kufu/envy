ENVY
---

お客様のブラウザで動作環境を判定し、その結果とブラウザの情報を画面に表示する静的ページです。
表示した内容はお客様にコピーしてお問い合わせ窓口へ送っていただきます。情報が自動で送信されることはありません。

- 動作環境の判定と表示する文面は https://system-requirements.smarthr.jp/envy.js (kufu/fumie) が作ります。
- `public/` 配下のファイルを Rack で配信しています。
- `?chat_id=<数字>` を付けてアクセスすると、表示内容にお問い合わせ番号として含めます。

ローカルでは `bundle exec rackup` で起動できます。

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Code of Conduct

Everyone interacting in the ENVY project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kufu/envy/blob/master/CODE_OF_CONDUCT.md).


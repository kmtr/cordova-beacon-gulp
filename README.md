beacon-cordova
===============

セットアップ
-----------

### 事前作業

以下のものをインストールしておきます

- xcode
- node.js
- npm (1.4x推奨)

npmで以下のコマンドを実行し、gulpをインストールしておきます。

```shell
#権限エラーが起きる場合は sudo をつける
npm install -g gulp
```

### セットアップ

以下のコマンドを実行する

```shell
npm install
gulp
$(npm bin)/cordova platform add ios
$(npm bin)/cordova plugin add https://github.com/petermetz/cordova-plugin-ibeacon.git
gulp cordova-run
```

開発
------

`src` ディレクトリ以下にHTML、JS、CSSで記述していきます。
画像ファイルはsrc/img以下に配置します。
javascriptはbrowserifyでモジュール管理されます。
`www` 以下はビルドシステム(gulp)が管理するため、触らないでください。

大まかな開発手順は以下のようになります。

1. `gulp watch`コマンドを実行(停止させない事)
2. srcディレクトリの下のファイルを追加、更新する
3. http://localhost:9001/ をブラウザで開いて確認する

src以下の変更は自動的にブラウザに反映されるため、リロードは必要ありません。
(若干のタイムラグはあります)

実機確認
-------

iPhoneで確認するには以下のコマンドを実行します。

```shell
gulp cordova-build
gulp cordova-run
```

beacon実装方法
--------------

### Beacon受信開始方法

```javascript
//browserifyでrequireする
window.beacon = require('./beacon');

var uuid = '00000000-752F-1001-B000-001C4D1A3E36';
var identifier = 'sample';

document.addEventListener('deviceready', function() {
  beacon.iBeaconDelegate();
  //ここでは一つのuuidしか拾っていないが複数受信することも可能
  var newBeacon = beacon.createBeacon(uuid, identifier);
  //monitoring
  beacon.startMonitoring(newBeacon);
  //ranging
  beacon.startRanging(newBeacon);
});
```

### Beacon受信時の動作のハンドリング

beacon受信処理は以下のcordova pluginに依存しています。

https://github.com/petermetz/cordova-plugin-ibeacon

このプラグインをラップしたスクリプトを使うことで、
Beacon受信時の処理を比較的簡単に書けるようにしています。

```javascript
$(document).ready(function() {
  window.addEventListener('didRangeBeaconsInRegion', function(e) {
    //ここにBeacon受信時の動作を記述する
    //具体的なbeacon情報はe.pluginResultで取得する
    var result = e.pluginResult
  });
});
```

e.pluginResultのデータ構造は以下のようになっています。

```json
{
  "beacons": [
    {
      "uuid": "00000000-752F-1001-B000-001C4D1A3E36",
      "proximity": "ProximityNear",
      "major": 0,
      "minor": 2
      "rssi": -52,
    },
    {
      "uuid": "00000000-752F-1001-B000-001C4D1A3E36",
      "proximity": "ProximityFar",
      "major": 0,
      "minor": 3
      "rssi": -22,
    },

  ],
  "eventType": "didRangeBeaconsInRegion",
  "region": {
    "typeName": "BeaconRegion",
    "uuid": "00000000-752F-1001-B000-001C4D1A3E36",
    "identifier": "playSpace"
  }
}
```

beaconsには受信した全てのbeaconが配列として格納される事に注意してください。
proximityに設定される文字列とその意味は以下の通りです。

- ProximityFar 遠い
- ProximityNear 近い
- ProximityImmediate 接触
- ProximityUnknown 不明

上記の文字列は定数、ProximityFar, ProximityNear, ProximityImmediate,
ProximityUnknownでも得られます。

### ブラウザで確認する場合のダミーbeaconの発信方法

```
var uuid = '00000000-752F-1001-B000-001C4D1A3E36'
//単発
dummyBeacon.fire(uuid, dummyBeacon.ProximityNear, 0, 2);
//複数
dummyBeacon.multiFire([
  [uuid, dummyBeacon.ProximityNear, 0, 4],
  [uuid, dummyBeacon.ProximityImmediate, 1, 1]]);
```

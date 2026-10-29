(function() {
  function generateEnvyValueNavigatorPlugins() {
    var ret = [],
        plugins = window.navigator.plugins,
        plugin;

    for (var i = 0, len = plugins.length; i < len; i++) {
      plugin = plugins[i];

      ret[i] = {
        name: plugin.name,
        description: plugin.description,
        version: plugin.version,
        filename: plugin.filename,
      }
    }

    return ret;
  }

  function generateEnvyValue() {
    var nav = window.navigator;

    return {
      'window.JSON': !!window.JSON,
      'window.localStorage': !!window.localStorage,
      'window.sessionStorage': !!window.sessionStorage,

      'navigator.appCodeName': nav.appCodeName,
      'navigator.appName': nav.appName,
      'navigator.appVersion': nav.appVersion,
      'navigator.cookieEnabled': nav.cookieEnabled,
      'navigator.language': nav.language,
      'navigator.maxTouchPoints': nav.maxTouchPoints,
      'navigator.onLine': nav.onLine,
      'navigator.platform': nav.platform,
      'navigator.product': nav.product,
      'navigator.productSub': nav.productSub,
      'navigator.userAgent': nav.userAgent,
      'navigator.vendor': nav.vendor,
      'navigator.vendorSub': nav.vendorSub,

      'navigator.plugins': generateEnvyValueNavigatorPlugins(),
    };
  }

  // 4 桁の 16 進数のトークン
  function generateInquiryToken() {
    var bytes = new Uint8Array(2);
    window.crypto.getRandomValues(bytes);

    return Array.prototype.map.call(bytes, function(b) {
      return ('0' + b.toString(16)).slice(-2);
    }).join('').toUpperCase();
  }

  // URL の chat_id は SP が問い合わせを判別するための数字なので、数字以外は表示しない
  function getChatId() {
    var chatId = new URLSearchParams(window.location.search).get('chat_id');

    return chatId !== null && /^\d{1,30}$/.test(chatId) ? chatId : null;
  }

  // envy.js は Slack 向けの文面を作るので、お客様の画面向けに絵文字コードと太字の記号を置き換える
  var SLACK_EMOJI = {
    ':white_check_mark:': '✅',
    ':warning:': '⚠️',
    ':x:': '❌',
    ':thinking_face:': '🤔',
  };

  function toPlainText(slackText) {
    return slackText
      .replace(/:[a-z_]+:/g, function(code) { return SLACK_EMOJI[code] || code; })
      .replace(/\*([^*\n]+)\*/g, '$1');
  }

  function buildResultText() {
    var message = document.getElementById('message').value;
    var chatId = getChatId();

    var content = {};
    content.inquery_token = generateInquiryToken();
    if (chatId !== null) {
      content.chat_id = chatId;
    }
    content.javascript_env = generateEnvyValue();

    var lines = [];
    if (chatId !== null) {
      lines.push('■お問い合わせ番号: ' + chatId);
    }
    lines.push(message === '' ? '■ユーザー環境: 判定できませんでした' : toPlainText(message));
    lines.push('');
    lines.push('詳細');
    lines.push(JSON.stringify(content, null, 2));

    return lines.join('\n');
  }

  function showResult() {
    var result = document.getElementById('result');

    document.getElementById('result-text').textContent = buildResultText();
    document.getElementById('copy-status').textContent = '';
    result.hidden = false;
    result.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  var copyButtonTimer = null;

  // コピーできたことが分かるよう、ボタンの表示を少しの間だけ切り替える
  function showCopied(button) {
    var label = button.querySelector('.buttonLabel');
    var icon = button.querySelector('.fa');

    label.textContent = 'コピーしました';
    icon.className = 'fa fa-fw fa-check';
    button.classList.add('isDone');

    clearTimeout(copyButtonTimer);
    copyButtonTimer = setTimeout(function() {
      label.textContent = '内容をコピーする';
      icon.className = 'fa fa-fw fa-clipboard';
      button.classList.remove('isDone');
    }, 2000);
  }

  function copyResult() {
    var text = document.getElementById('result-text').textContent;
    var status = document.getElementById('copy-status');
    var button = document.getElementById('copy-button');

    if (!navigator.clipboard) {
      status.textContent = 'コピーできませんでした。表示された内容を選択してコピーしてください。';
      return;
    }

    navigator.clipboard.writeText(text).then(function() {
      status.textContent = '';
      showCopied(button);
    }, function() {
      status.textContent = 'コピーできませんでした。表示された内容を選択してコピーしてください。';
    });
  }

  document.getElementById('show-button').addEventListener('click', showResult);
  document.getElementById('copy-button').addEventListener('click', copyResult);
})();

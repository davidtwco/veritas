---
template: empty.html
title: Per-site Email Generator | David Wood
---
<p id="email-generator">Not yet generated! Is JavaScript enabled?</p>

<script type="text/javascript">
    var urlParams = new URLSearchParams(window.location.search);

    var characters = urlParams.get('chars') ||  'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var domain = urlParams.get('domain') || 'david.davidtw.co';
    var length = parseInt(urlParams.get('length'), 25);

    var result = '';
    for (var i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    result += '@';
    result += domain;

    document.getElementById('email-generator').innerHTML = result;
</script>

<!--
  vim:foldmethod=marker:foldlevel=0:et:ts=2:sts=2:sw=2:et:nowrap
-->

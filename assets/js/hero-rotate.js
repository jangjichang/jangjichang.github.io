document.addEventListener('DOMContentLoaded', function () {
  var phrases = (window.__heroPhrases || []).filter(Boolean);
  if (phrases.length === 0) return;

  var el = document.querySelector('#phrase-active');
  if (!el) return;

  var index = 0;
  var delay = 5000;
  var fade = 500;

  el.textContent = phrases[index];
  index = (index + 1) % phrases.length;

  function rotate() {
    el.classList.add('fade-out');
    setTimeout(function () {
      el.textContent = phrases[index];
      el.classList.remove('fade-out');
      index = (index + 1) % phrases.length;
    }, fade);
  }

  setInterval(rotate, delay);
});

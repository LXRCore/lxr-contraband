/* LXR-CONTRABAND — the contract note | © 2026 iBoss21 / LXRCore */
(function () {
  const $ = (id) => document.getElementById(id);
  const card = $('card');
  let L = {}, deadline = 0, timer = null;
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  const money = (n) => (Math.round((Number(n) || 0) * 100) / 100).toFixed(2);
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }
  function tick() { const s = Math.max(0, Math.floor(deadline - Date.now() / 1000)); $('clock').textContent = `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`; }
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.locale) { L = m.locale; applyLocale(); }
    if (m.lang) document.body.classList.toggle('lang-ka', m.lang === 'ka');
    if (m.action === 'show') { const p = m.payload || {}; $('goods').textContent = `${p.amount} × ${p.label}`; $('drop').textContent = p.drop || ''; $('pay').textContent = '$' + money(p.pay); deadline = Number(p.deadline) || (Date.now() / 1000 + (Number(p.minutes) || 0) * 60); tick(); clearInterval(timer); timer = setInterval(tick, 1000); card.classList.remove('lxr-hidden'); }
    if (m.action === 'hide') { card.classList.add('lxr-hidden'); clearInterval(timer); }
  });
  if (window.__LXR_MOCK__) window.postMessage(window.__LXR_MOCK__, '*');
})();

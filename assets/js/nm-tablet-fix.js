(()=>{
  function q(sel){return document.querySelector(sel)}
  function fix(){
    const w = window.innerWidth;
    if (w<768 || w>1025) return;
    const img = q('img[src*="iphone.webp"]');
    if(!img) return;
    img.style.opacity='1'; img.style.visibility='visible'; img.style.display='block';
    let el = img;
    for (let i=0;i<7 && el;i++){
      el = el.parentElement;
      if(!el) break;
      if (el.classList && (el.classList.contains('elementor-column') || el.classList.contains('e-con') || el.classList.contains('elementor-container'))) {
        el.style.minHeight = '560px';
        el.style.display = 'block';
        el.style.opacity = '1';
        el.style.visibility = 'visible';
        break;
      }
    }
  }
  window.addEventListener('DOMContentLoaded', fix);
  window.addEventListener('resize', fix);
})();
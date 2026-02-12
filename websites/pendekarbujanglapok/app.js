// === Pendekar Bujang Lapok V1 ===

document.addEventListener('DOMContentLoaded', () => {
    initMobile();
    initReveal();
    initNavScroll();
});

// === Mobile Menu ===
function initMobile() {
    const btn = document.getElementById('hamburger');
    const menu = document.getElementById('mobileMenu');
    btn.addEventListener('click', () => {
        btn.classList.toggle('open');
        menu.classList.toggle('open');
    });
    menu.querySelectorAll('a').forEach(a => {
        a.addEventListener('click', () => {
            btn.classList.remove('open');
            menu.classList.remove('open');
        });
    });
}

// === Scroll Reveal ===
function initReveal() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((e, i) => {
            if (e.isIntersecting) {
                setTimeout(() => e.target.classList.add('visible'), i * 80);
            }
        });
    }, { threshold: 0.12 });

    document.querySelectorAll('[data-reveal]').forEach(el => observer.observe(el));
}

// === Nav scroll effect ===
function initNavScroll() {
    const nav = document.getElementById('navbar');
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
        const y = window.scrollY;
        if (y > 100) {
            nav.style.boxShadow = '0 2px 16px rgba(60,36,21,0.08)';
        } else {
            nav.style.boxShadow = 'none';
        }
        lastScroll = y;
    });
}

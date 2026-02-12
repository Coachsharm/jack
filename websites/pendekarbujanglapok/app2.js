// === Pendekar Bujang Lapok V2 ===

document.addEventListener('DOMContentLoaded', () => {
    initMobile();
    initReveal();
    initNavScroll();
    initLightbox();
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

// === Scroll Reveal with stagger ===
function initReveal() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((e, i) => {
            if (e.isIntersecting) {
                setTimeout(() => e.target.classList.add('visible'), i * 60);
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('[data-reveal]').forEach(el => observer.observe(el));
}

// === Nav shadow on scroll ===
function initNavScroll() {
    const nav = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        nav.style.boxShadow = window.scrollY > 80
            ? '0 2px 16px rgba(60,36,21,0.06)'
            : 'none';
    });
}

// === Lightbox for gallery ===
function initLightbox() {
    const lb = document.getElementById('lightbox');
    const lbImg = document.getElementById('lbImg');
    const lbCaption = document.getElementById('lbCaption');
    const lbClose = document.getElementById('lbClose');

    document.querySelectorAll('.g-item').forEach(item => {
        item.addEventListener('click', () => {
            const img = item.querySelector('img');
            const label = item.querySelector('.g-label');
            lbImg.src = img.src;
            lbImg.alt = img.alt;
            lbCaption.textContent = label ? label.textContent : '';
            lb.classList.add('open');
            document.body.style.overflow = 'hidden';
        });
    });

    function closeLb() {
        lb.classList.remove('open');
        document.body.style.overflow = '';
    }

    lbClose.addEventListener('click', closeLb);
    lb.addEventListener('click', (e) => {
        if (e.target === lb) closeLb();
    });
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeLb();
    });
}

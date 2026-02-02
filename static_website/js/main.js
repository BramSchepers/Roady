/**
 * Roady – Landing Page
 * Smooth scroll, mobile nav, and light interactions
 */

(function () {
  'use strict';

  // Theme toggle (dark mode switch)
  var themeToggle = document.getElementById('theme-toggle');
  var html = document.documentElement;

  function applyTheme(isDark) {
    if (isDark) {
      html.setAttribute('data-theme', 'dark');
      if (themeToggle) themeToggle.checked = true;
      localStorage.setItem('theme', 'dark');
    } else {
      html.removeAttribute('data-theme');
      if (themeToggle) themeToggle.checked = false;
      localStorage.setItem('theme', 'light');
    }
  }

  function initThemeToggle() {
    if (!themeToggle) return;
    var saved = localStorage.getItem('theme');
    themeToggle.checked = saved === 'dark';
    if (themeToggle.checked) html.setAttribute('data-theme', 'dark');
    themeToggle.addEventListener('change', function () {
      applyTheme(themeToggle.checked);
    });
  }

  initThemeToggle();

  // Language dropdown
  var langDropdown = document.getElementById('nav-lang-dropdown');
  var langTrigger = document.getElementById('nav-lang-trigger');
  var langMenu = document.getElementById('nav-lang-menu');

  if (langDropdown && langTrigger && langMenu) {
    function openLangDropdown() {
      langDropdown.classList.add('is-open');
      langTrigger.setAttribute('aria-expanded', 'true');
      langMenu.setAttribute('aria-hidden', 'false');
    }

    function closeLangDropdown() {
      langDropdown.classList.remove('is-open');
      langTrigger.setAttribute('aria-expanded', 'false');
      langMenu.setAttribute('aria-hidden', 'true');
    }

    langTrigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (langDropdown.classList.contains('is-open')) {
        closeLangDropdown();
      } else {
        openLangDropdown();
      }
    });

    document.addEventListener('click', function () {
      if (langDropdown.classList.contains('is-open')) {
        closeLangDropdown();
      }
    });

    langDropdown.addEventListener('click', function (e) {
      e.stopPropagation();
    });

    langMenu.querySelectorAll('.nav__lang-item[href]').forEach(function (link) {
      link.addEventListener('click', function () {
        closeLangDropdown();
      });
    });
  }

  // Footer year (auto-update)
  document.querySelectorAll('.footer__year').forEach(function (el) {
    el.textContent = new Date().getFullYear();
  });

  // Mobile navigation toggle
  const navToggle = document.querySelector('.nav__toggle');
  const nav = document.querySelector('.nav');
  const navOverlay = document.getElementById('nav-overlay');

  function setNavOpen(open) {
    if (!nav) return;
    if (open) {
      nav.classList.add('is-open');
      if (navOverlay) {
        navOverlay.classList.add('is-open');
        navOverlay.setAttribute('aria-hidden', 'false');
      }
      if (navToggle) {
        navToggle.setAttribute('aria-expanded', 'true');
        navToggle.setAttribute('aria-label', 'Menu sluiten');
      }
    } else {
      nav.classList.remove('is-open');
      if (navOverlay) {
        navOverlay.classList.remove('is-open');
        navOverlay.setAttribute('aria-hidden', 'true');
      }
      if (navToggle) {
        navToggle.setAttribute('aria-expanded', 'false');
        navToggle.setAttribute('aria-label', 'Menu openen');
      }
    }
  }

  if (navToggle && nav) {
    navToggle.addEventListener('click', function () {
      setNavOpen(!nav.classList.contains('is-open'));
    });

    if (navOverlay) {
      navOverlay.addEventListener('click', function () {
        setNavOpen(false);
      });
    }

    // Sluit menu bij klik/tap buiten het menu (overlay, header, etc.)
    document.addEventListener('click', function (e) {
      if (!nav.classList.contains('is-open')) return;
      if (nav.contains(e.target) || navToggle.contains(e.target)) return;
      setNavOpen(false);
    });

    // Close nav when clicking a link (for anchor links)
    nav.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        setNavOpen(false);
      });
    });
  }

  // Smooth scroll for anchor links (enhancement – CSS scroll-behavior already handles basics)
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener('click', function (e) {
      const href = this.getAttribute('href');
      if (href === '#') return;

      const target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // Optional: Fade-in on scroll for sections (with reduced-motion check)
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const observerOptions = {
      root: null,
      rootMargin: '0px 0px -80px 0px',
      threshold: 0.1
    };

    const observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
        }
      });
    }, observerOptions);

    document.querySelectorAll('.features .section__title, .features .section__subtitle, .feature-card, .mockup, .pricing-card').forEach(function (el) {
      el.classList.add('animate-on-scroll');
      observer.observe(el);
    });
  }

  // Scroll fade for sections: fade in when entering, then stay at full opacity
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const scrollFadeEls = document.querySelectorAll('.scroll-fade');
    let scrollFadeTicking = false;

    function updateScrollFade() {
      const viewHeight = window.innerHeight;
      const fadeInThreshold = viewHeight * 0.75;
      scrollFadeEls.forEach(function (el) {
        if (el.dataset.fadeDone === '1') {
          el.style.opacity = '1';
          return;
        }
        const rect = el.getBoundingClientRect();
        const elTop = rect.top;
        if (elTop < fadeInThreshold) {
          el.dataset.fadeDone = '1';
          el.style.opacity = '1';
        } else {
          const distance = elTop - fadeInThreshold;
          const fadeZone = viewHeight * 0.3;
          const opacity = Math.max(0, 1 - distance / fadeZone);
          el.style.opacity = String(opacity);
        }
      });
      scrollFadeTicking = false;
    }

    function onScrollFade() {
      if (scrollFadeTicking) return;
      scrollFadeTicking = true;
      requestAnimationFrame(updateScrollFade);
    }

    window.addEventListener('scroll', onScrollFade, { passive: true });
    updateScrollFade();
  }

  // Hero scroll fade: text left, mascot/gsm right (only when reduced-motion is off)
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const hero = document.querySelector('.hero');
    const heroContent = document.querySelector('.hero__content');
    const heroVisual = document.querySelector('.hero__visual');
    const offsetPx = 80;
    let ticking = false;

    function updateHeroScrollFade() {
      if (!hero || !heroContent || !heroVisual) return;
      const rect = hero.getBoundingClientRect();
      const viewHeight = window.innerHeight;
      let progress = 1 - rect.bottom / viewHeight;
      progress = Math.max(0, Math.min(1, progress));
      heroContent.style.transform = 'translateX(' + (-progress * offsetPx) + 'px)';
      heroContent.style.opacity = String(1 - progress);
      heroVisual.style.transform = 'translateX(' + progress * offsetPx + 'px)';
      heroVisual.style.opacity = String(1 - progress);
      ticking = false;
    }

    function onScroll() {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(updateHeroScrollFade);
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    updateHeroScrollFade();
  }

  // Back to top
  const backToTop = document.querySelector('.back-to-top');
  if (backToTop) {
    function updateBackToTop() {
      if (window.scrollY > 300) {
        backToTop.classList.add('is-visible');
      } else {
        backToTop.classList.remove('is-visible');
      }
    }

    window.addEventListener('scroll', updateBackToTop, { passive: true });
    updateBackToTop();

    backToTop.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  // Pricing carousel (mobile only)
  const pricingGrid = document.querySelector('.pricing__grid');
  const pricingCards = document.querySelectorAll('.pricing-card');
  const prevArrow = document.querySelector('.pricing__arrow--prev');
  const nextArrow = document.querySelector('.pricing__arrow--next');
  const dots = document.querySelectorAll('.pricing__dot');

  if (pricingGrid && pricingCards.length > 0 && window.innerWidth < 640) {
    let currentIndex = 1; // Start at middle card (Standaard €4,99)

    // Initialize - scroll to middle card
    function scrollToCard(index, smooth = true) {
      const card = pricingCards[index];
      if (card) {
        const scrollLeft = card.offsetLeft - (pricingGrid.offsetWidth - card.offsetWidth) / 2;
        pricingGrid.scrollTo({
          left: scrollLeft,
          behavior: smooth ? 'smooth' : 'auto'
        });
      }
    }

    // Update active states
    function updateActiveStates(index) {
      currentIndex = index;

      // Update dots
      dots.forEach(function (dot, i) {
        if (i === index) {
          dot.classList.add('is-active');
        } else {
          dot.classList.remove('is-active');
        }
      });

      // Update arrows
      if (prevArrow && nextArrow) {
        prevArrow.disabled = index === 0;
        nextArrow.disabled = index === pricingCards.length - 1;
      }
    }

    // Get current card index based on scroll position
    function getCurrentIndex() {
      const scrollLeft = pricingGrid.scrollLeft;
      const cardWidth = pricingCards[0].offsetWidth;
      const gap = parseInt(getComputedStyle(pricingGrid).gap) || 0;
      return Math.round(scrollLeft / (cardWidth + gap));
    }

    // Arrow navigation
    if (prevArrow) {
      prevArrow.addEventListener('click', function () {
        if (currentIndex > 0) {
          scrollToCard(currentIndex - 1);
          updateActiveStates(currentIndex - 1);
        }
      });
    }

    if (nextArrow) {
      nextArrow.addEventListener('click', function () {
        if (currentIndex < pricingCards.length - 1) {
          scrollToCard(currentIndex + 1);
          updateActiveStates(currentIndex + 1);
        }
      });
    }

    // Dot navigation
    dots.forEach(function (dot, index) {
      dot.addEventListener('click', function () {
        scrollToCard(index);
        updateActiveStates(index);
      });
    });

    // Touch/swipe support
    let touchStartX = 0;
    let touchEndX = 0;

    pricingGrid.addEventListener('touchstart', function (e) {
      touchStartX = e.changedTouches[0].screenX;
    }, { passive: true });

    pricingGrid.addEventListener('touchend', function (e) {
      touchEndX = e.changedTouches[0].screenX;
      handleSwipe();
    }, { passive: true });

    function handleSwipe() {
      const swipeThreshold = 50;
      const diff = touchStartX - touchEndX;

      if (Math.abs(diff) > swipeThreshold) {
        if (diff > 0 && currentIndex < pricingCards.length - 1) {
          // Swipe left - next
          scrollToCard(currentIndex + 1);
          updateActiveStates(currentIndex + 1);
        } else if (diff < 0 && currentIndex > 0) {
          // Swipe right - prev
          scrollToCard(currentIndex - 1);
          updateActiveStates(currentIndex - 1);
        }
      }
    }

    // Update on scroll (for manual scroll)
    let scrollTimeout;
    pricingGrid.addEventListener('scroll', function () {
      clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(function () {
        const newIndex = getCurrentIndex();
        if (newIndex !== currentIndex && newIndex >= 0 && newIndex < pricingCards.length) {
          updateActiveStates(newIndex);
        }
      }, 150);
    }, { passive: true });

    // Initialize
    setTimeout(function () {
      scrollToCard(1, false); // Start at middle card without animation
      updateActiveStates(1);
    }, 100);

    // Re-initialize on resize if still mobile
    let resizeTimeout;
    window.addEventListener('resize', function () {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(function () {
        if (window.innerWidth < 640) {
          scrollToCard(currentIndex, false);
        }
      }, 250);
    });
  }
})();

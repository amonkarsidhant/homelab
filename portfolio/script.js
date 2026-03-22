// Theme toggle with localStorage + system preference
const themeBtn = document.getElementById('theme-toggle');
const body = document.body;

function applyTheme(theme) {
  if (theme === 'dark') {
    body.classList.add('dark-mode');
    localStorage.setItem('theme', 'dark');
  } else {
    body.classList.remove('dark-mode');
    localStorage.setItem('theme', 'light');
  }
}

// Init from localStorage or system
const saved = localStorage.getItem('theme');
const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
applyTheme(saved || (systemDark ? 'dark' : 'light'));

themeBtn.addEventListener('click', () => {
  applyTheme(body.classList.contains('dark-mode') ? 'light' : 'dark');
});

// Smooth scroll polyfill for older browsers (optional)
// Already using CSS scroll-behavior: smooth

// Year update in footer
document.getElementById('year').textContent = new Date().getFullYear();

// Accessibility: focus visible for skip link
document.querySelector('.skip-link')?.addEventListener('click', (e) => {
  const target = document.querySelector(e.target.getAttribute('href'));
  if (target) {
    target.setAttribute('tabindex', '-1');
    target.focus();
  }
});

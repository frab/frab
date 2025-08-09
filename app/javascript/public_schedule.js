// JavaScript for public schedule pages with dark mode support
// Compatible with main application's theme system

function getCurrentTheme() {
  const savedTheme = localStorage.getItem('frab-theme');
  if (savedTheme) return savedTheme;
  const currentTheme = document.documentElement.getAttribute('data-bs-theme');
  if (currentTheme) return currentTheme;
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  return systemPrefersDark ? 'dark' : 'light';
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-bs-theme', theme);
  localStorage.setItem('frab-theme', theme);
  updateUI();
}

function updateUI() {
  const toggleButton = document.getElementById('dark-mode-toggle');
  if (toggleButton) {
    const currentTheme = getCurrentTheme();
    const isDark = currentTheme === 'dark';
    const icon = toggleButton.querySelector('i');
    if (icon) {
      icon.className = `bi ${isDark ? 'bi-sun-fill' : 'bi-moon-fill'}`;
    }
    toggleButton.title = isDark ? 'Switch to light mode' : 'Switch to dark mode';
  }
}

function toggleDarkMode() {
  const currentTheme = getCurrentTheme();
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  setTheme(newTheme);
}

// Make function available globally
window.toggleDarkMode = toggleDarkMode;

// Initialize on DOM load
document.addEventListener('DOMContentLoaded', function() {
  const initialTheme = getCurrentTheme();
  setTheme(initialTheme);
});

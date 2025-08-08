// Initialize theme on page load (before DOM content loads to prevent flashing)
(function() {
  // Get saved theme, system preference, or default to light
  const savedTheme = localStorage.getItem('frab-theme')
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  const initialTheme = savedTheme || (systemPrefersDark ? 'dark' : 'light')

  // Apply theme immediately to prevent flash of wrong theme
  document.documentElement.setAttribute('data-bs-theme', initialTheme)
})();

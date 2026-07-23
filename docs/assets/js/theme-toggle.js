/**
 * Theme Toggle for Breaking Free from Autopilot
 * Handles light/dark theme switching with localStorage persistence
 */

(function() {
  'use strict';

  const STORAGE_KEY = 'bf-theme-preference';
  const THEME_LIGHT = 'light';
  const THEME_DARK = 'slate';

  /**
   * Get the current theme from localStorage or system preference
   */
  function getTheme() {
    // Check localStorage first
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored && (stored === THEME_LIGHT || stored === THEME_DARK)) {
      return stored;
    }

    // Fall back to system preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
      return THEME_LIGHT;
    }

    return THEME_DARK;
  }

  /**
   * Set the theme on the document
   */
  function setTheme(theme) {
    const body = document.body;
    const html = document.documentElement;

    if (theme === THEME_LIGHT) {
      body.setAttribute('data-md-color-scheme', THEME_LIGHT);
      html.setAttribute('data-md-color-scheme', THEME_LIGHT);
    } else {
      body.setAttribute('data-md-color-scheme', THEME_DARK);
      html.setAttribute('data-md-color-scheme', THEME_DARK);
    }

    // Store preference
    localStorage.setItem(STORAGE_KEY, theme);

    // Update toggle button if it exists
    updateToggleButton(theme);

    // Dispatch custom event for other scripts
    window.dispatchEvent(new CustomEvent('themechange', { detail: { theme } }));
  }

  /**
   * Toggle between light and dark themes
   */
  function toggleTheme() {
    const current = getTheme();
    const next = current === THEME_LIGHT ? THEME_DARK : THEME_LIGHT;
    setTheme(next);
  }

  /**
   * Update the toggle button appearance
   */
  function updateToggleButton(theme) {
    const btn = document.querySelector('.theme-toggle');
    if (!btn) return;

    const isLight = theme === THEME_LIGHT;
    btn.setAttribute('aria-label', isLight ? 'Switch to dark theme' : 'Switch to light theme');
    btn.setAttribute('title', isLight ? 'Switch to dark theme' : 'Switch to light theme');

    // Update icon
    const icon = btn.querySelector('.theme-toggle__icon') || btn;
    icon.textContent = isLight ? '🌙' : '☀️';
  }

  /**
   * Create the theme toggle button
   */
  function createToggleButton() {
    const header = document.querySelector('.md-header__inner') || document.querySelector('.md-header');
    if (!header) return;

    // Check if button already exists
    if (header.querySelector('.theme-toggle')) return;

    const btn = document.createElement('button');
    btn.className = 'theme-toggle';
    btn.setAttribute('type', 'button');
    btn.setAttribute('aria-label', 'Toggle theme');
    btn.innerHTML = '<span class="theme-toggle__icon"></span>';

    // Add styles inline for the button
    btn.style.cssText = `
      background: transparent;
      border: 1px solid var(--bf-primary-600);
      border-radius: 8px;
      padding: 6px 10px;
      cursor: pointer;
      font-size: 1.1rem;
      transition: all 0.25s ease;
      margin-left: 12px;
      margin-right: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 36px;
      height: 36px;
    `;

    btn.addEventListener('click', toggleTheme);
    btn.addEventListener('mouseenter', function() {
      this.style.borderColor = 'var(--bf-accent-cyan)';
      this.style.background = 'var(--bf-accent-cyan-hover)';
    });
    btn.addEventListener('mouseleave', function() {
      this.style.borderColor = 'var(--bf-primary-600)';
      this.style.background = 'transparent';
    });

    // Place the toggle on the right of the header, grouped with the other
    // header controls (repo link) rather than floating between the title and
    // the search box in the middle of the bar.
    const source = header.querySelector('.md-header__source');
    const search = header.querySelector('.md-search');
    if (source) {
      header.insertBefore(btn, source);
    } else if (search && search.nextSibling) {
      header.insertBefore(btn, search.nextSibling);
    } else {
      header.appendChild(btn);
    }

    updateToggleButton(getTheme());
  }

  /**
   * Initialize theme on page load
   */
  function init() {
    const theme = getTheme();
    setTheme(theme);

    // Create toggle button when DOM is ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', createToggleButton);
    } else {
      createToggleButton();
    }

    // Also try after a short delay to ensure Material theme is loaded
    setTimeout(createToggleButton, 100);
    setTimeout(createToggleButton, 500);

    // Listen for system theme changes
    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: light)');
      mediaQuery.addEventListener('change', function(e) {
        // Only auto-switch if user hasn't manually set a preference
        if (!localStorage.getItem(STORAGE_KEY)) {
          setTheme(e.matches ? THEME_LIGHT : THEME_DARK);
        }
      });
    }
  }

  // Expose API globally for debugging and external use
  window.ThemeToggle = {
    get: getTheme,
    set: setTheme,
    toggle: toggleTheme
  };

  // Initialize
  init();
})();

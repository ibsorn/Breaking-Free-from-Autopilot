/**
 * Code Block Enhancer - Breaking Free from Autopilot
 * Wraps code blocks with headers and copy buttons
 */

(function() {
  'use strict';

  function enhanceCodeBlocks() {
    const codeBlocks = document.querySelectorAll('.md-typeset pre > code');

    codeBlocks.forEach(function(codeBlock) {
      // Skip if already enhanced
      if (codeBlock.closest('.code-block-wrapper')) return;

      const pre = codeBlock.parentElement;
      const highlight = pre.closest('.highlight');

      // Detect language from class
      let language = 'text';
      const classes = codeBlock.className.split(' ');
      for (const cls of classes) {
        if (cls.startsWith('language-')) {
          language = cls.replace('language-', '');
          break;
        }
      }

      // Create wrapper
      const wrapper = document.createElement('div');
      wrapper.className = 'code-block-wrapper';

      // Create header
      const header = document.createElement('div');
      header.className = 'code-block-header';
      header.innerHTML = `
        <span class="code-block-header__lang">${language}</span>
        <button class="code-block-header__copy" type="button" aria-label="Copy code">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
          Copy
        </button>
      `;

      // Insert wrapper before highlight
      if (highlight) {
        highlight.parentNode.insertBefore(wrapper, highlight);
        wrapper.appendChild(header);
        wrapper.appendChild(highlight);
      } else {
        pre.parentNode.insertBefore(wrapper, pre);
        wrapper.appendChild(header);
        wrapper.appendChild(pre);
      }

      // Add copy functionality
      const copyBtn = header.querySelector('.code-block-header__copy');
      copyBtn.addEventListener('click', function() {
        const code = codeBlock.textContent;
        navigator.clipboard.writeText(code).then(function() {
          copyBtn.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            Copied!
          `;
          copyBtn.style.color = 'var(--bf-accent-green)';
          copyBtn.style.borderColor = 'var(--bf-accent-green)';

          setTimeout(function() {
            copyBtn.innerHTML = `
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              Copy
            `;
            copyBtn.style.color = '';
            copyBtn.style.borderColor = '';
          }, 2000);
        }).catch(function(err) {
          console.error('Failed to copy:', err);
          copyBtn.textContent = 'Failed';
          setTimeout(function() {
            copyBtn.innerHTML = `
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              Copy
            `;
          }, 2000);
        });
      });
    });
  }

  function init() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', enhanceCodeBlocks);
    } else {
      enhanceCodeBlocks();
    }
    // Re-run after delay for dynamically loaded content
    setTimeout(enhanceCodeBlocks, 500);
    setTimeout(enhanceCodeBlocks, 1500);
  }

  init();
})();

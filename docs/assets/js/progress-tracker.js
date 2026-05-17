/**
 * Progress Tracker for Breaking Free from Autopilot
 * Tracks completion status of 9 phases with localStorage persistence
 */

(function() {
  'use strict';

  const STORAGE_KEY = 'bf-phase-progress';

  // Phase configuration
  const PHASES = [
    { id: 1, name: 'Deep Hardware Cleanup', slug: 'phase1', required: true },
    { id: 2, name: 'Edition Selection', slug: 'phase2', required: true },
    { id: 3, name: 'Clean Installation', slug: 'phase3', required: true },
    { id: 4, name: 'Key Purging', slug: 'phase4', required: true },
    { id: 5, name: 'Telemetry & MDM Kill', slug: 'phase5', required: true },
    { id: 6, name: 'Hosts File Block', slug: 'phase6', required: true },
    { id: 7, name: 'Firewall Blocking', slug: 'phase7', required: true },
    { id: 8, name: 'Hosts Watchdog', slug: 'phase8', required: false },
    { id: 9, name: 'Final Connection', slug: 'phase9', required: true }
  ];

  /**
   * Get stored progress from localStorage
   */
  function getProgress() {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        return JSON.parse(stored);
      }
    } catch (e) {
      console.warn('Error reading progress:', e);
    }
    return {};
  }

  /**
   * Save progress to localStorage
   */
  function saveProgress(progress) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
    } catch (e) {
      console.warn('Error saving progress:', e);
    }
  }

  /**
   * Mark a phase as completed or not
   */
  function setPhaseComplete(phaseId, complete) {
    const progress = getProgress();
    progress[phaseId] = {
      complete: complete,
      timestamp: complete ? new Date().toISOString() : null
    };
    saveProgress(progress);
    updatePhaseNavigator();
  }

  /**
   * Toggle phase completion status
   */
  function togglePhaseComplete(phaseId) {
    const progress = getProgress();
    const isComplete = progress[phaseId] && progress[phaseId].complete;
    setPhaseComplete(phaseId, !isComplete);
  }

  /**
   * Check if a phase is complete
   */
  function isPhaseComplete(phaseId) {
    const progress = getProgress();
    return progress[phaseId] && progress[phaseId].complete;
  }

  /**
   * Get current phase from URL
   */
  function getCurrentPhase() {
    const path = window.location.pathname;
    const match = path.match(/phase(\d+)/);
    if (match) {
      return parseInt(match[1], 10);
    }
    return 0; // Homepage
  }

  /**
   * Calculate overall progress percentage
   */
  function getOverallProgress() {
    const progress = getProgress();
    const completed = PHASES.filter(p => progress[p.id] && progress[p.id].complete).length;
    return Math.round((completed / PHASES.length) * 100);
  }

  /**
   * Get next incomplete phase
   */
  function getNextPhase() {
    const current = getCurrentPhase();
    for (let i = 1; i <= 9; i++) {
      if (i > current && !isPhaseComplete(i)) {
        return i;
      }
    }
    return null;
  }

  /**
   * Get previous phase
   */
  function getPrevPhase() {
    const current = getCurrentPhase();
    return current > 1 ? current - 1 : null;
  }

  /**
   * Update the phase navigator UI
   */
  function updatePhaseNavigator() {
    const currentPhase = getCurrentPhase();
    if (currentPhase === 0) return; // Not on a phase page

    const progress = getProgress();
    const navigator = document.querySelector('.phase-navigator');
    if (!navigator) return;

    // Update progress text
    const progressText = navigator.querySelector('.phase-navigator__progress');
    if (progressText) {
      const percent = getOverallProgress();
      const completed = Object.values(progress).filter(p => p.complete).length;
      progressText.textContent = `${completed}/9 completed (${percent}%)`;
    }

    // Update phase steps
    const steps = navigator.querySelectorAll('.phase-step');
    steps.forEach((step, index) => {
      const phaseNum = index + 1;
      step.classList.remove('phase-step--completed', 'phase-step--current');

      if (phaseNum === currentPhase) {
        step.classList.add('phase-step--current');
      } else if (isPhaseComplete(phaseNum)) {
        step.classList.add('phase-step--completed');
      }

      // Update click handler
      step.onclick = function() {
        window.location.href = `/${PHASES[index].slug}/`;
      };
    });

    // Update navigation buttons
    const prevBtn = navigator.querySelector('.phase-nav-btn--prev');
    const nextBtn = navigator.querySelector('.phase-nav-btn--next');

    if (prevBtn) {
      const prevPhase = getPrevPhase();
      if (prevPhase) {
        prevBtn.href = `/${PHASES[prevPhase - 1].slug}/`;
        prevBtn.classList.remove('phase-nav-btn--disabled');
        prevBtn.innerHTML = `<span class="phase-nav-btn__icon">←</span> Phase ${prevPhase}`;
      } else {
        prevBtn.href = '/';
        prevBtn.innerHTML = `<span class="phase-nav-btn__icon">←</span> Home`;
      }
    }

    if (nextBtn) {
      const nextPhase = currentPhase < 9 ? currentPhase + 1 : null;
      if (nextPhase) {
        nextBtn.href = `/${PHASES[nextPhase - 1].slug}/`;
        nextBtn.classList.remove('phase-nav-btn--disabled');
        nextBtn.innerHTML = `Phase ${nextPhase} <span class="phase-nav-btn__icon">→</span>`;
      } else {
        nextBtn.classList.add('phase-nav-btn--disabled');
        nextBtn.innerHTML = `Complete <span class="phase-nav-btn__icon">✓</span>`;
      }
    }
  }

  /**
   * Create the phase navigator HTML
   */
  function createPhaseNavigator() {
    const currentPhase = getCurrentPhase();
    if (currentPhase === 0) return; // Don't create on homepage

    // Check if already exists
    if (document.querySelector('.phase-navigator')) return;

    const content = document.querySelector('.md-content__inner');
    if (!content) return;

    const progress = getProgress();
    const percent = getOverallProgress();
    const completed = Object.values(progress).filter(p => p.complete).length;

    const navigator = document.createElement('div');
    navigator.className = 'phase-navigator';
    navigator.innerHTML = `
      <div class="phase-navigator__header">
        <span class="phase-navigator__title">Phase Progress</span>
        <span class="phase-navigator__progress">${completed}/9 completed (${percent}%)</span>
      </div>
      <div class="phase-navigator__bar">
        ${PHASES.map((p, i) => {
          const phaseNum = i + 1;
          let classes = 'phase-step';
          if (phaseNum === currentPhase) classes += ' phase-step--current';
          else if (isPhaseComplete(phaseNum)) classes += ' phase-step--completed';
          return `<div class="${classes}" data-phase="${phaseNum}" title="${p.name}"></div>`;
        }).join('')}
      </div>
      <div class="phase-navigator__labels">
        <span>Start</span>
        <span>Required</span>
        <span>Optional</span>
        <span>Complete</span>
      </div>
      <div class="phase-navigator__controls">
        <a class="phase-nav-btn phase-nav-btn--prev" href="/"></a>
        <a class="phase-nav-btn phase-nav-btn--next" href="/"></a>
      </div>
    `;

    // Insert after the first H1
    const h1 = content.querySelector('h1');
    if (h1) {
      h1.insertAdjacentElement('afterend', navigator);
    } else {
      content.insertBefore(navigator, content.firstChild);
    }

    updatePhaseNavigator();

    // Add complete button to page
    addPhaseCompleteButton(currentPhase);
  }

  /**
   * Add a "Mark as Complete" button to the page
   */
  function addPhaseCompleteButton(phaseId) {
    // Check if already exists
    if (document.querySelector('.phase-complete-btn')) return;

    const content = document.querySelector('.md-content__inner');
    if (!content) return;

    const complete = isPhaseComplete(phaseId);

    const btn = document.createElement('button');
    btn.className = 'phase-complete-btn';
    btn.innerHTML = complete ?
      '<span class="phase-complete-btn__icon">✓</span> Phase Completed' :
      '<span class="phase-complete-btn__icon">○</span> Mark Phase as Complete';

    btn.style.cssText = `
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 12px 20px;
      font-size: 0.95rem;
      font-weight: 600;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.25s ease;
      margin: 2rem 0;
      border: 2px solid ${complete ? 'var(--bf-accent-green)' : 'var(--bf-accent-cyan)'};
      background: ${complete ? 'rgba(34, 197, 94, 0.1)' : 'transparent'};
      color: ${complete ? 'var(--bf-accent-green)' : 'var(--bf-accent-cyan)'} !important;
    `;

    btn.addEventListener('click', function() {
      togglePhaseComplete(phaseId);
      const nowComplete = isPhaseComplete(phaseId);

      this.style.borderColor = nowComplete ? 'var(--bf-accent-green)' : 'var(--bf-accent-cyan)';
      this.style.background = nowComplete ? 'rgba(34, 197, 94, 0.1)' : 'transparent';
      this.style.color = nowComplete ? 'var(--bf-accent-green)' : 'var(--bf-accent-cyan)';
      this.innerHTML = nowComplete ?
        '<span class="phase-complete-btn__icon">✓</span> Phase Completed' :
        '<span class="phase-complete-btn__icon">○</span> Mark Phase as Complete';

      // Update navigator
      updatePhaseNavigator();

      // Dispatch event
      window.dispatchEvent(new CustomEvent('phasecomplete', {
        detail: { phaseId, complete: nowComplete }
      }));
    });

    // Insert before the footer or at the end
    const footer = content.querySelector('.md-content__inner > *:last-child');
    if (footer) {
      footer.insertAdjacentElement('beforebegin', btn);
    } else {
      content.appendChild(btn);
    }
  }

  /**
   * Initialize progress tracking
   */
  function init() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', createPhaseNavigator);
    } else {
      createPhaseNavigator();
    }

    // Also try after delay for Material theme
    setTimeout(createPhaseNavigator, 100);
    setTimeout(createPhaseNavigator, 500);
  }

  // Expose API globally
  window.PhaseTracker = {
    getProgress,
    setPhaseComplete,
    togglePhaseComplete,
    isPhaseComplete,
    getCurrentPhase,
    getOverallProgress,
    PHASES
  };

  // Initialize
  init();
})();

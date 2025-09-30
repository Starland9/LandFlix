// Main JavaScript file for LandFlix Landing Page
class LandFlixApp {
    constructor() {
        this.init();
    }

    init() {
        this.setupSmoothScrolling();
        this.setupMobileMenu();
        this.setupScrollAnimations();
        this.setupHeaderBackground();
        this.setupScreenshotCarousel();
        this.setupDownloadButtons();
        this.setupFloatingElements();
    }

    // Smooth scrolling for navigation links
    setupSmoothScrolling() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    }

    // Mobile menu functionality
    setupMobileMenu() {
        const mobileMenuBtn = document.getElementById('mobile-menu');
        const navLinks = document.querySelector('.nav-links');

        if (mobileMenuBtn && navLinks) {
            mobileMenuBtn.addEventListener('click', () => {
                navLinks.classList.toggle('active');
                const icon = mobileMenuBtn.querySelector('i');
                icon.classList.toggle('fa-bars');
                icon.classList.toggle('fa-times');
            });

            // Close mobile menu when clicking on a link
            document.querySelectorAll('.nav-links a').forEach(link => {
                link.addEventListener('click', () => {
                    navLinks.classList.remove('active');
                    const icon = mobileMenuBtn.querySelector('i');
                    icon.classList.add('fa-bars');
                    icon.classList.remove('fa-times');
                });
            });
        }
    }

    // Scroll animations using Intersection Observer
    setupScrollAnimations() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                }
            });
        }, observerOptions);

        // Observe all elements with fade-in class
        document.querySelectorAll('.fade-in, .slide-in-right').forEach(el => {
            observer.observe(el);
        });
    }

    // Header background on scroll
    setupHeaderBackground() {
        const header = document.getElementById('header');
        let scrolled = false;

        window.addEventListener('scroll', () => {
            const scrollTop = window.pageYOffset;

            if (scrollTop > 50 && !scrolled) {
                header.classList.add('scrolled');
                scrolled = true;
            } else if (scrollTop <= 50 && scrolled) {
                header.classList.remove('scrolled');
                scrolled = false;
            }
        });
    }

    // Screenshots carousel functionality
    setupScreenshotCarousel() {
        const carousel = document.querySelector('.screenshots-carousel');
        if (!carousel) return;

        let currentIndex = 0;
        const items = carousel.querySelectorAll('.screenshot-item');

        // Auto-scroll every 4 seconds
        setInterval(() => {
            currentIndex = (currentIndex + 1) % items.length;
            this.scrollToScreenshot(currentIndex);
        }, 4000);

        // Add click handlers for manual navigation
        items.forEach((item, index) => {
            item.addEventListener('click', () => {
                currentIndex = index;
                this.scrollToScreenshot(index);
            });
        });
    }

    scrollToScreenshot(index) {
        const carousel = document.querySelector('.screenshots-carousel');
        const items = carousel.querySelectorAll('.screenshot-item');

        if (items[index]) {
            items[index].scrollIntoView({
                behavior: 'smooth',
                block: 'nearest',
                inline: 'center'
            });
        }
    }

    // Download buttons with analytics tracking
    setupDownloadButtons() {
        document.querySelectorAll('.download-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                const platform = btn.dataset.platform;

                // Add click animation
                btn.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    btn.style.transform = '';
                }, 150);

                // Track download intent
                this.trackDownload(platform);

                // Show download modal or redirect
                this.handleDownload(platform);
            });
        });
    }

    trackDownload(platform) {
        // Analytics tracking would go here
        console.log(`Download initiated for platform: ${platform}`);

        // Example: Google Analytics event
        if (typeof gtag !== 'undefined') {
            gtag('event', 'download_click', {
                'platform': platform,
                'event_category': 'engagement'
            });
        }
    }

    handleDownload(platform) {
        // For now, show an alert with download info
        // In production, this would redirect to actual download links
        const messages = {
            android: 'Téléchargement Android disponible bientôt sur Google Play Store',
            ios: 'Téléchargement iOS disponible bientôt sur l\'App Store',
            windows: 'Téléchargement Windows disponible sur GitHub Releases',
            mac: 'Téléchargement macOS disponible sur GitHub Releases'
        };

        this.showDownloadModal(platform, messages[platform]);
    }

    showDownloadModal(platform, message) {
        // Create and show a modern modal
        const modal = document.createElement('div');
        modal.className = 'download-modal';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Téléchargement ${platform.charAt(0).toUpperCase() + platform.slice(1)}</h3>
                    <button class="modal-close">&times;</button>
                </div>
                <div class="modal-body">
                    <div class="modal-icon">
                        <i class="fas fa-download"></i>
                    </div>
                    <p>${message}</p>
                    <div class="modal-buttons">
                        <button class="btn btn-primary" onclick="window.open('https://github.com/LandryMbende/landflix', '_blank')">
                            <i class="fab fa-github"></i>
                            Voir sur GitHub
                        </button>
                        <button class="btn btn-secondary modal-close-btn">Fermer</button>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        // Add closing functionality
        modal.querySelectorAll('.modal-close, .modal-close-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                modal.remove();
            });
        });

        // Close on backdrop click
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });

        // Animate in
        setTimeout(() => modal.classList.add('show'), 10);
    }

    // Floating elements animation
    setupFloatingElements() {
        const floatingElements = document.querySelectorAll('.floating-card');

        floatingElements.forEach((element, index) => {
            // Add random floating animation
            const duration = 3000 + (index * 500);
            const delay = index * 200;

            element.style.animationDuration = `${duration}ms`;
            element.style.animationDelay = `${delay}ms`;
        });
    }

    // Utility method for debouncing
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // Performance optimization for scroll events
    optimizeScrollEvents() {
        const debouncedScroll = this.debounce(() => {
            // Scroll-dependent operations
        }, 16); // ~60fps

        window.addEventListener('scroll', debouncedScroll, { passive: true });
    }
}

// Additional CSS for modals (injected via JavaScript)
const modalStyles = `
.download-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.download-modal.show {
    opacity: 1;
}

.modal-content {
    background: var(--dark-surface);
    border-radius: 24px;
    padding: 0;
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
    border: 1px solid var(--dark-surface-variant);
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
    transform: scale(0.9);
    transition: transform 0.3s ease;
}

.download-modal.show .modal-content {
    transform: scale(1);
}

.modal-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--dark-surface-variant);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: var(--text-primary);
    font-size: 1.25rem;
    font-weight: 600;
}

.modal-close {
    background: none;
    border: none;
    color: var(--text-secondary);
    font-size: 1.5rem;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 12px;
    transition: all 0.2s ease;
}

.modal-close:hover {
    background: var(--dark-surface-variant);
    color: var(--text-primary);
}

.modal-body {
    padding: 2rem 1.5rem;
    text-align: center;
}

.modal-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto 1.5rem;
    background: var(--primary-gradient);
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 30px rgba(139, 93, 255, 0.3);
}

.modal-icon i {
    font-size: 2rem;
    color: white;
}

.modal-body p {
    color: var(--text-secondary);
    margin-bottom: 2rem;
    line-height: 1.6;
}

.modal-buttons {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.modal-buttons .btn {
    min-width: 140px;
}

@media (max-width: 768px) {
    .modal-content {
        margin: 1rem;
        width: calc(100% - 2rem);
    }
    
    .modal-buttons {
        flex-direction: column;
    }
    
    .modal-buttons .btn {
        width: 100%;
        min-width: auto;
    }
}
`;

// Inject modal styles
const styleSheet = document.createElement('style');
styleSheet.textContent = modalStyles;
document.head.appendChild(styleSheet);

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new LandFlixApp();
});

// Smooth loading experience
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});

// Handle window resize for responsive adjustments
window.addEventListener('resize', () => {
    // Responsive adjustments if needed
});

// Export for potential external use
window.LandFlixApp = LandFlixApp;
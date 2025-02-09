// Fonction pour faire défiler vers une section
function scrollToSection(sectionId) {
    const section = document.getElementById(sectionId);
    gsap.to(window, { duration: 1, scrollTo: section });
}

// Parallax effect
gsap.to('.parallax', {
    scrollTrigger: {
        trigger: '.hero',
        scrub: true,
    },
    y: '-50%',
});

// Animations ScrollTrigger
gsap.from('.about', {
    scrollTrigger: {
        trigger: '.about',
        toggleActions: 'play none none reverse',
    },
    opacity: 0,
    y: 50,
    duration: 1,
});

gsap.from('.projects', {
    scrollTrigger: {
        trigger: '.projects',
        toggleActions: 'play none none reverse',
    },
    opacity: 0,
    y: 50,
    duration: 1,
});

gsap.from('.contact', {
    scrollTrigger: {
        trigger: '.contact',
        toggleActions: 'play none none reverse',
    },
    opacity: 0,
    y: 50,
    duration: 1,
});

// Dark Mode Toggle
const themeToggle = document.getElementById('theme-toggle');
themeToggle.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
    if (document.body.classList.contains('dark-mode')) {
        themeToggle.textContent = '☀️';
    } else {
        themeToggle.textContent = '🌙';
    }
});

// Validation du formulaire de contact
document.getElementById('contact-form').addEventListener('submit', function (e) {
    e.preventDefault();
    alert('Merci pour votre message !');
    this.reset();
});
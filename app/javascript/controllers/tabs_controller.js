import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["tab", "content"]

    connect() {
        const urlParams = new URLSearchParams(window.location.search);
        const tabParam = urlParams.get('tab');

        if (tabParam) {
            this.activateTab(tabParam);
        }
    }

    switch(event) {
        event.preventDefault();

        const tab = event.currentTarget.dataset.tab;
        this.activateTab(tab);

        // Update URL
        const url = new URL(window.location.href);
        if (tab === 'history') {
            url.searchParams.set('tab', 'history');
        } else {
            url.searchParams.delete('tab');
        }

        history.pushState({}, '', url);
    }

    activateTab(tab) {
        this.tabTargets.forEach((element) => {
            const isActive = element.dataset.tab === tab;
            const underline = element.querySelector('div:last-child'); // Get the underline element

            // Manage active tab styling
            if (isActive) {
                // Apply active styles
                element.classList.add('text-indigo-700');
                element.classList.remove('text-indigo-900', 'group-hover:text-indigo-700');

                // Show the underline by setting scale-x-100
                if (underline) {
                    underline.classList.remove('scale-x-0');
                    underline.classList.add('scale-x-100');
                }

                // Add a subtle background color to the active tab
                const iconContainer = element.querySelector('div.rounded-full');
                if (iconContainer) {
                    iconContainer.classList.add('bg-indigo-200');
                    iconContainer.classList.remove('bg-indigo-100');
                }
            } else {
                // Remove active styles
                element.classList.remove('text-indigo-700');
                element.classList.add('text-indigo-900', 'group-hover:text-indigo-700');

                // Hide the underline by setting scale-x-0
                if (underline) {
                    underline.classList.add('scale-x-0');
                    underline.classList.remove('scale-x-100');
                }

                // Reset the background color of the icon container
                const iconContainer = element.querySelector('div.rounded-full');
                if (iconContainer) {
                    iconContainer.classList.remove('bg-indigo-200');
                    iconContainer.classList.add('bg-indigo-100');
                }
            }
        });

        this.contentTargets.forEach((element) => {
            const shouldShow = element.dataset.tab === tab;

            // Add a fade transition effect
            if (shouldShow) {
                element.classList.remove('hidden');
                // Use setTimeout to ensure the transition happens after the display change
                setTimeout(() => {
                    element.classList.add('opacity-100');
                    element.classList.remove('opacity-0');
                }, 10);
            } else {
                element.classList.add('opacity-0');
                element.classList.remove('opacity-100');
                // Hide the element after the transition completes
                setTimeout(() => {
                    element.classList.add('hidden');
                }, 300); // Match this with the CSS transition duration
            }
        });
    }
}

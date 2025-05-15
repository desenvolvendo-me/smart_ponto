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

            // Manage active tab styling
            if (isActive) {
                element.classList.add('border-b-2', 'border-blue-500', 'text-blue-600');
                element.classList.remove('text-gray-500');
            } else {
                element.classList.remove('border-b-2', 'border-blue-500', 'text-blue-600');
                element.classList.add('text-gray-500');
            }
        });

        this.contentTargets.forEach((element) => {
            const shouldShow = element.dataset.tab === tab;
            element.classList.toggle('hidden', !shouldShow);
        });
    }
}
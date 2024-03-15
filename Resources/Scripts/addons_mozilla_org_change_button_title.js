let hasMutationOccurred = false;

function updateButton() {
    const elements = document.querySelectorAll('.InstallButtonWrapper .AMInstallButton .AMInstallButton-button');
    if (elements.length > 0) {
        elements[0].innerText = 'Add to Orion';
    }
}

window.onload = (event) => {
    const currentHostname = window.location.hostname;
    if (currentHostname === 'addons.mozilla.org') {
        updateButton();
        
        const targetNode = document.body;
        const config = { childList: true, subtree: true };
        
        const observer = new MutationObserver((mutationList, observer) => {
            if (mutationList.length > 0) {
                if (!hasMutationOccurred) {
                    hasMutationOccurred = true;

                    setTimeout(() => {
                        observer.disconnect();
                        
                        updateButton();
                        hasMutationOccurred = false;
                        
                        observer.observe(targetNode, config);
                    }, 50);
                }
            }
        });

        observer.observe(targetNode, config);
    }
};

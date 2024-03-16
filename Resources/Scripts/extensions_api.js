const Methods = {
    GET_TOP_SITES: 'getTopSites',
    CREATE_TAB: 'createTab',
    UPDATE_TAB: 'updateTab',
};

var browser = {};

browser.topSites = {
    get: function() {
        return window.webkit.messageHandlers.extension.postMessage({
            method: Methods.GET_TOP_SITES
        }).then(response => {
            return response;
        });
    }
};

browser.storage = {
    local: {
        get: function() {
            return Promise.resolve({ new_tab: false });
        }
    }
};

browser.tabs = {
    create: function({url}) {
        window.webkit.messageHandlers.extension.postMessage({
            method: Methods.CREATE_TAB, url: url
        });
    },
    update: function({url}) {
        window.webkit.messageHandlers.extension.postMessage({
            method: Methods.UPDATE_TAB, url: url
        });
    }
};

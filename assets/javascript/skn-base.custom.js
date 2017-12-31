/**
 * Created by jscott on 1/1/16.
 * Refs: https://github.com/rweng/jquery-datatables-rails
 *       http://api.jquery.com/jQuery.getJSON/
 *       http://getbootstrap.com/components/#panels
 *       http://datatables.net
 */


var logEnabled = true,
    SknService,
    accessibleUrl,
    userTable,
    accessTable,
    contentTable,
    accessibleTable,
    mcUserTable,
    mcEntriesTable,
    siStorageTable,
    membersTable;

/**
 * Prevents debuging messages from going to console none development mode
 * @param message {string}  to log on console
 */
function consoleLog(message) {
    if (logEnabled) {
        console.log(message);
    }
}


/**
 * SknBaseUtil
 *
 *  - desired usage pattern:
 *
 *    var SknBase = new SknBaseObject();
 *    SknBase.go('/controller/action');     => redirect to page
 *    SknBase.context('controller/action'); => true|false
 *
 */
;function SknBaseUtil() {
    this.relativeUrlPath = $('body').data('relative-path');
    this.controllerName = $('body').data('request-path');
    this.controllerAction = $('body').data('request-matched');
    this.currentPage = ($('body').data('request-path') + '/' + $('body').data('request-matched'));
    this.csrfToken = $('meta[name="_csrf"]').attr('content');

    if (typeof this.relativeUrlPath === "undefined")  {
        this.relativeUrlPath = '';
    }

};

SknBaseUtil.prototype = {
    get csrf() {
        return this.csrfToken;
    },
    get page() {
        return this.currentPage;
    },
    get relativePath() {
        return this.relativeUrlPath;
    },
    set relativePath(str) {
        this.relativeUrlPath = str;
    },
    get controller() {
        return this.controllerName;
    },
    get action() {
        return this.controllerAction;
    },
    context: function(path){
        return this.currentPage === path;
    },
    genURL: function(path) {
        var x = window.location.href.split('/'),
            urlPath = '',
            urlBase = '';

        if (this.relativeUrlPath.length > 1) { // is this a controller name or relative prefix
            if ( path.startsWith(this.relativeUrlPath) ) {
                urlPath = urlBase.concat(x[0], '//', x[2], path);
            } else {
                urlPath = urlBase.concat(x[0], '//', x[2], '/', x[3], path);
            }
        } else { // path include leading slash
            urlPath = urlBase.concat(x[0], '//', x[2], path);
        }
        return urlPath;

    },
    go: function(path) {
        window.location = this.genURL(path);
    }
};

/* ********************************************************
 * ContentProfileDemo Page: :in_action_admin
 * ********************************************************
 */

/*
 * For Runtime Demo Page Selections */
function runtimeDemoGetObject(ev) {
    var dataPackage = $(ev.currentTarget).data().package,
        dataResponse,
        objectUrl = $('#accordion').data().accessibleUrl + "?id=" + dataPackage.id + ";username=" + dataPackage.username + ";content_type=" + dataPackage.content_type;

    ev.preventDefault();

    if(dataPackage.hasOwnProperty('id')) {
        window.open(objectUrl, dataPackage.filename);
        consoleLog("runtimeDemoGetObject(" + dataPackage.username + ":" + dataPackage.id + ") Tab opened for file: " + dataPackage.filename);
    } else {
        consoleLog("runtimeDemoGetObject() Not a file based request - skipped");
    }

    consoleLog("runtimeDemoGetObject(completed) ");

    return false;
}

/**
 * Handle In Action page Initialization
 */
function handle_in_action() {
    $('div.well.runtime-item').on("click", runtimeDemoGetObject);

    $('div.well-sm[data-mh="files-group"]').matchHeight();
    $.fn.matchHeight._update();

    $('#accordion').on('show.bs.collapse', function() {
        $.fn.matchHeight._update();
    });

    return true;
}


/* ********************************************************
 * JQuery Enabled Processing
 * ********************************************************
 */
$(function() {

    /*
     * Create the general utility object
    */
    SknBase = new SknBaseUtil();

    switch (SknBase.action) {

        case 'in_action':
            handle_in_action();
            break;

        default:
            consoleLog("Current Page (" + SknBase.page + ") has no custom Javascripts enabled.");
    }


    /* Timeout non-Error Flash messages
     * { alert: :alert, notice: :success, info: :info, secondary: :secondary, success: :success, error: :alert, warning: :warning, primary: :primary }
     */
    setTimeout(function() { // all except alert
        var elems = $('div.alert.alert-success,.alert.alert-notice,.alert.alert-info,.alert.alert-warning');
        $.each( elems, function (index, item) {
            $(item).slideUp(2000);
        });
    }, 20000); // <-- time in milliseconds


    consoleLog("Initialization Complete for: " + SknBase.page + ".");

    return false;
});


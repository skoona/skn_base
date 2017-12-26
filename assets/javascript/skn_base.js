
/**
 * Prevents debuging messages from going to console none development mode
 * @param message {string}  to log on console
 */
function consoleLog(message) {
    if (logEnabled) {
        console.log(message);
    }
}

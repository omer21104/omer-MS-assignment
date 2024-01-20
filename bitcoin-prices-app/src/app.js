const { iterationHandler } = require("./helpers/main-helper");

const minute = 60 * 1000;

setInterval(() => iterationHandler(), minute);

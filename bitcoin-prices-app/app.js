const { iterationHandler } = require("./src/helpers/main-helper");

const main = async () => {
  setInterval(() => iterationHandler(), 2000);
};

main();

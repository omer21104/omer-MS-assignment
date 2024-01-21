const express = require("express");
const { iterationHandler } = require("./helpers/main-helper");

const app = express();
const port = 3000;
const minute = 60 * 1000;
const intervalOverride = process.env.INTERVAL; // for testing with shorter interval
const interval = intervalOverride || minute;

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.get("/ready", (req, res) => {
  if (taskId) {
    res.status(200).send("OK");
  } else {
    res.status(503).send("Service Unavailable");
  }
});

const taskId = setInterval(() => iterationHandler(), interval);

app.listen(port, () => console.log("listening on port: ", port));

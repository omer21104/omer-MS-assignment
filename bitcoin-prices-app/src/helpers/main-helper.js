const { getBitcoinValue } = require("../services/bitcoin-price");

const lastValues = [];
const minutesToAverage = 10;

const iterationHandler = async () => {
  const currentValue = await getBitcoinValue();
  if (!currentValue) {
    return;
  }

  console.log(
    `--- Current Bitcoin price (USD) is: $${currentValue.toFixed(2)} ---`
  );
  lastValues.push(currentValue);

  if (lastValues.length === minutesToAverage) {
    const avg = lastValues.reduce((sum, curr) => sum + curr) / minutesToAverage;
    console.log(
      `--- Average Bitcoin price (USD) in the last ${minutesToAverage} minutes is: $${avg.toFixed(
        2
      )} ---`
    );
    lastValues.length = 0;
  }
};

module.exports = { iterationHandler };

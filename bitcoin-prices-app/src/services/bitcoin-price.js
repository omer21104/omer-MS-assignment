const axios = require("axios");

const apiUrl = "https://api.coindesk.com/v1/bpi/currentprice/BTC.json";

const getBitcoinValue = async () => {
  try {
    const response = await axios.get(apiUrl);
    const bitcoinValue = response.data.bpi.USD.rate_float;

    return bitcoinValue;
  } catch (error) {
    console.error("Error fetching Bitcoin value:", error.message);
  }
};

module.exports = { getBitcoinValue };

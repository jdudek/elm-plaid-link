var express = require('express');
var bodyParser = require('body-parser');
var plaid = require('plaid');

var app = express();
app.use(bodyParser.json());

var plaidClient = new plaid.Client(process.env.PLAID_CLIENT_ID,
                                   process.env.PLAID_SECRET,
                                   plaid.environments.tartan);

app.post('/authenticate', function(req, res) {
  var publicToken = req.body.public_token;

  // Exchange a public_token for a Plaid access_token
  plaidClient.exchangeToken(publicToken, function(err, exchangeTokenRes) {
    if (err != null) {
      // Handle error!
      console.log(err);
    } else {
      // This is your Plaid access token - store somewhere persistent
      // The access_token can be used to make Plaid API calls to
      // retrieve accounts and transactions
      var accessToken = exchangeTokenRes.access_token;

      plaidClient.getAuthUser(accessToken, function(err, authRes) {
        if (err != null) {
          // Handle error!
          console.log(err);
        } else {
          // An array of accounts for this user, containing account
          // names, balances, and account and routing numbers.
          var accounts = authRes.accounts;

          // Return account data
          res.json({accounts: accounts});
        }
      });
    }
  });
});

app.use(express.static('public'));

app.listen(process.env.APP_PORT || 3000);

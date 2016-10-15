var express = require('express');
var plaid = require('plaid');

var app = express();
var plaidClient = new plaid.Client(process.env.PLAID_CLIENT_ID,
                                   process.env.PLAID_SECRET,
                                   plaid.environments.tartan);

app.use(['/accounts', '/transactions'], function(req, res, next) {
  var publicToken = req.query.public_token;

  plaidClient.exchangeToken(publicToken, function(err, exchangeTokenRes) {
    if (err != null) {
      console.log(err);
      res.status(500).send('Error when exchanging tokens!');
    } else {
      res.locals.accessToken = exchangeTokenRes.access_token;
      next();
    }
  });
});

app.get('/accounts', function(req, res) {
  plaidClient.getAuthUser(res.locals.accessToken, function(err, apiRes) {
    if (err != null) {
      console.log(err);
      res.status(500).send('Error when accessing accounts!');
    } else {
      var accounts = apiRes.accounts;
      res.json({accounts: accounts});
    }
  });
});

app.get('/transactions', function(req, res) {
  plaidClient.getConnectUser(res.locals.accessToken, function(err, apiRes) {
    if (err != null) {
      console.log(err);
      res.status(500).send('Error when accessing transactions!');
    } else {
      var transactions = apiRes.transactions;
      res.json({transactions: transactions});
    }
  });
});

app.use(express.static('public'));
app.listen(process.env.PORT || 3000);

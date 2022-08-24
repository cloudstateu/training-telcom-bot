const fs = require('fs');
const https = require('https');
const axios = require('axios');
const config = require('./config');

const httpsAgent = new https.Agent({
  cert: fs.readFileSync('./sms/cert.pem'),
  key: fs.readFileSync('./sms/cert.pem')
});

// sms function
module.exports = async function(context, req) {
  let result = null;

  try {
    if (!(req.body && req.body.recipient && req.body.content && req.body.msisdn)) {
      throw new Error(`Invalid input. Current req.body: ${JSON.stringify(req.body)}`);
    }

    const xml = replace(config.requests.createShipment, [
      { key: '{{TRANSACTION_ID}}', value: `PGG${Date.now()}` },
      { key: '{{TIMESTAMP}}', value: new Date().toISOString() },
      { key: '{{MSISDN}}', value: req.body.msisdn },
      { key: /\{\{RECIPIENT\}\}/g, value: req.body.recipient },
      { key: '{{CONTENT}}', value: req.body.content }
    ]);

    const soapResponse = await soapRequest({
      url: config.url.api,
      headers: {
        'Content-Type': 'text/xml;charset=UTF-8',
        SOAPAction: 'createShipment'
      },
      xml
    });

    let isSuccessful = soapResponse.response.body.match(/<status>OK<\/status>/g);

    if (isSuccessful) {
      result = {
        body: {
          status: 'ok',
          data: null
        }
      };
    } else {
      throw new Error('Unsuccessful request to external SMS API. API response: ' + soapResponse.response.body);
    }
  } catch (err) {
    result = { body: { status: 'failure', error: err.message }, status: 400 };
    console.log(err);
  }

  context.res = {
    ...result
  };
};

function soapRequest(
  opts = {
    url: '',
    headers: {},
    xml: '',
    timeout: 10000,
    proxy: false
  }
) {
  const { url, headers, xml, timeout, proxy } = opts;
  return new Promise((resolve, reject) => {
    axios({
      method: 'post',
      url,
      headers,
      data: xml,
      timeout,
      proxy,
      httpsAgent
    })
      .then((response) => {
        resolve({
          response: {
            headers: response.headers,
            body: response.data,
            statusCode: response.status
          }
        });
      })
      .catch((error) => {
        if (error.response) {
          console.error(`SOAP FAIL: ${error}`);
          reject(error.response.data);
        } else {
          console.error(`SOAP FAIL: ${error}`);
          reject(error);
        }
      });
  });
}

function replace(xml, replacements) {
  let result = xml;
  for (let pair of replacements) {
    result = result.replace(pair.key, pair.value);
  }
  return result;
}

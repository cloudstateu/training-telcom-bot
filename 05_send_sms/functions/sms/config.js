const url = {
  api: 'https://superinfo.t-mobile.pl/superinfoapi2'
};

const requests = {
  createShipment: `<sup2:SupRequest xsi:schemaLocation="http://superinfo.t-mobile.pl/api2 api-supera2.xsd" xmlns:sup2="http://superinfo.t-mobile.pl/api2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <header>
         <transactionId>{{TRANSACTION_ID}}</transactionId>
         <timestamp>{{TIMESTAMP}}</timestamp>
         <nws>48608921133</nws>
         <MSISDN>{{MSISDN}}</MSISDN>
    </header>
    <createShipment>
       <sender>
          <nws/>
       </sender>
       <messages>
          <singleContent>
             <content>{{CONTENT}}</content>
             <recipient>
                <MSISDN>{{RECIPIENT}}</MSISDN>
             </recipient>
          </singleContent>
       </messages>
       <comment>
          <comment>comment</comment>
       </comment>
       <ttl>DAY</ttl>
         <normalize>true</normalize>
    </createShipment>
    </sup2:SupRequest>`
};

module.exports = {
  requests,
  url
};

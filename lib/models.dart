
class Ticker {
  String instrumentToken; // get data from kite
  String exchangeToken;
  String tradingSymbol;
  String name;
  String expiry; // 2019-10-14
  String strike; // 26500
  String tickSize;
  String lotSize; // 20
  String instrumentType; // EQ, FUT, CE, PE
  String segment;
  String exchange;

  Ticker({
    this.instrumentToken, // get data from kite
    this.exchangeToken,
    this.tradingSymbol,
    this.name,
    this.expiry, // 2019-10-14
    this.strike, // 26500
    this.tickSize,
    this.lotSize, // 20
    this.instrumentType, // EQ, FUT, CE, PE
    this.segment,
    this.exchange,
  });
}

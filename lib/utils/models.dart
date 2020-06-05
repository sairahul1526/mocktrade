// account

class Accounts {
  final List<Account> accounts;
  final Meta meta;
  final Pagination pagination;

  Accounts({this.accounts, this.meta, this.pagination});

  factory Accounts.fromJson(Map<String, dynamic> json) {
    return Accounts(
      accounts: json['data'] != null
          ? List<Account>.from(json['data'].map((i) => Account.fromJson(i)))
          : new List<Account>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Account {
  final String id;
  final String userID;
  final String name;
  final String phone;
  final String watchlist;
  final String amount;
  final String status;
  final String createdDateTime;
  final String modifiedDateTime;

  Account(
      {this.id,
      this.userID,
      this.name,
      this.phone,
      this.watchlist,
      this.amount,
      this.status,
      this.createdDateTime,
      this.modifiedDateTime});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userID: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      watchlist: json['watchlist'],
      amount: json['amount'],
      status: json['status'],
      createdDateTime: json['created_date_time'],
      modifiedDateTime: json['modified_date_time'],
    );
  }
}

// amount

class Amounts {
  final List<Amount> amounts;
  final Meta meta;
  final Pagination pagination;

  Amounts({this.amounts, this.meta, this.pagination});

  factory Amounts.fromJson(Map<String, dynamic> json) {
    return Amounts(
      amounts: json['data'] != null
          ? List<Amount>.from(json['data'].map((i) => Amount.fromJson(i)))
          : new List<Amount>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Amount {
  final String id;
  final String userID;
  final String amount;
  final String date;

  Amount({this.id, this.userID, this.amount, this.date});

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      id: json['id'],
      userID: json['user_id'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}

// login

class Logins {
  final List<Login> logins;
  final Meta meta;
  final Pagination pagination;

  Logins({this.logins, this.meta, this.pagination});

  factory Logins.fromJson(Map<String, dynamic> json) {
    return Logins(
      logins: json['data'] != null
          ? List<Login>.from(json['data'].map((i) => Login.fromJson(i)))
          : new List<Login>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Login {
  final String url;

  Login({this.url});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      url: json['url'],
    );
  }
}

// ticker last

class TickerLasts {
  final List<TickerLast> tickerLasts;
  final Meta meta;
  final Pagination pagination;

  TickerLasts({this.tickerLasts, this.meta, this.pagination});

  factory TickerLasts.fromJson(Map<String, dynamic> json) {
    return TickerLasts(
      tickerLasts: json['data'] != null
          ? List<TickerLast>.from(
              json['data'].map((i) => TickerLast.fromJson(i)))
          : new List<TickerLast>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class TickerLast {
  final String key;
  final String value;

  TickerLast({
    this.key,
    this.value,
  });

  factory TickerLast.fromJson(Map<String, dynamic> json) {
    return TickerLast(
      key: json['k'],
      value: json['v'],
    );
  }
}

// timing

class Timings {
  final List<Timing> timings;
  final Meta meta;
  final Pagination pagination;

  Timings({this.timings, this.meta, this.pagination});

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      timings: json['data'] != null
          ? List<Timing>.from(json['data'].map((i) => Timing.fromJson(i)))
          : new List<Timing>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Timing {
  final String id;
  final String day;
  final String holiday;
  final String open;
  final String close;
  final String status;
  final String createdDateTime;
  final String modifiedDateTime;

  Timing(
      {this.id,
      this.day,
      this.holiday,
      this.open,
      this.close,
      this.status,
      this.createdDateTime,
      this.modifiedDateTime});

  factory Timing.fromJson(Map<String, dynamic> json) {
    return Timing(
      id: json['id'],
      day: json['day'],
      holiday: json['holiday'],
      open: json['open'],
      close: json['close'],
      status: json['status'],
      createdDateTime: json['created_date_time'],
      modifiedDateTime: json['modified_date_time'],
    );
  }
}

// token

class Tokens {
  final List<Token> tokens;
  final Meta meta;
  final Pagination pagination;

  Tokens({this.tokens, this.meta, this.pagination});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      tokens: json['data'] != null
          ? List<Token>.from(json['data'].map((i) => Token.fromJson(i)))
          : new List<Token>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Token {
  final String token;
  final String userID;

  Token({
    this.token,
    this.userID,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'],
      userID: json['userid'],
    );
  }
}

// order

class Orders {
  final List<Order> orders;
  final Meta meta;
  final Pagination pagination;

  Orders({this.orders, this.meta, this.pagination});

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      orders: json['data'] != null
          ? List<Order>.from(json['data'].map((i) => Order.fromJson(i)))
          : new List<Order>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Order {
  final String id;
  final String userID;
  final String ticker;
  final String name;
  final String exchange;
  final String price;
  final String shares;
  final String invested;
  final String type;
  final String status;
  final String createdDateTime;
  final String modifiedDateTime;

  Order(
      {this.id,
      this.userID,
      this.ticker,
      this.name,
      this.exchange,
      this.price,
      this.shares,
      this.invested,
      this.type,
      this.status,
      this.createdDateTime,
      this.modifiedDateTime});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userID: json['user_id'],
      ticker: json['ticker'],
      name: json['name'],
      exchange: json['exchange'],
      price: json['price'],
      shares: json['shares'],
      invested: json['invested'],
      type: json['type'],
      status: json['status'],
      createdDateTime: json['created_date_time'],
      modifiedDateTime: json['modified_date_time'],
    );
  }
}

// position

class Positions {
  final List<Position> positions;
  final Meta meta;
  final Pagination pagination;

  Positions({this.positions, this.meta, this.pagination});

  factory Positions.fromJson(Map<String, dynamic> json) {
    return Positions(
      positions: json['data'] != null
          ? List<Position>.from(json['data'].map((i) => Position.fromJson(i)))
          : new List<Position>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Position {
  final String id;
  final String userID;
  final String ticker;
  final String name;
  String invested;
  String shares;
  final String status;
  final String expiry;
  final String createdDateTime;
  final String modifiedDateTime;

  Position(
      {this.id,
      this.userID,
      this.ticker,
      this.name,
      this.invested,
      this.shares,
      this.status,
      this.expiry,
      this.createdDateTime,
      this.modifiedDateTime});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      userID: json['user_id'],
      ticker: json['ticker'],
      name: json['name'],
      invested: json['invested'],
      shares: json['shares'],
      expiry: json['expiry'],
      status: json['status'],
      createdDateTime: json['created_date_time'],
      modifiedDateTime: json['modified_date_time'],
    );
  }
}

// ticker

class Tickers {
  final List<Ticker> tickers;
  final Meta meta;
  final Pagination pagination;

  Tickers({this.tickers, this.meta, this.pagination});

  factory Tickers.fromJson(Map<String, dynamic> json) {
    return Tickers(
      tickers: json['data'] != null
          ? List<Ticker>.from(json['data'].map((i) => Ticker.fromJson(i)))
          : new List<Ticker>(),
      meta: Meta.fromJson(json['meta']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

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

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      instrumentToken: json['i'], // get data from kite
      exchangeToken: json['e'],
      tradingSymbol: json['t'],
      name: json['n'],
      expiry: json['ex'], // 2019-10-14
      strike: json['s'], // 26500
      tickSize: json['ti'],
      lotSize: json['l'], // 20
      instrumentType: json['in'], // EQ, FUT, CE, PE
      segment: json['se'],
      exchange: json['exc'],
    );
  }
}

class Meta {
  final String status;
  final String message;
  final String messageType;

  Meta({this.status, this.message, this.messageType});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      status: json['status'],
      message: json['message'],
      messageType: json['message_type'],
    );
  }
}

class Pagination {
  final String count;
  final String offset;
  final String totalCount;

  Pagination({this.count, this.offset, this.totalCount});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      count: json['count'],
      offset: json['offset'],
      totalCount: json['total_count'],
    );
  }
}

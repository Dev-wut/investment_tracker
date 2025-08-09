import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:decimal/decimal.dart';
import '../models/investment.dart';
import '../utils/constants.dart';

class InvestmentService {
  static const String _alphaVantageBaseUrl = 'https://www.alphavantage.co/query';
  static const String _coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';

  // ดึงราคาหุ้น
  Future<Decimal?> getStockPrice(String symbol) async {
    try {
      final url = Uri.parse(
          '$_alphaVantageBaseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=${AppConstants.alphaVantageApiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = data['Global Quote'];

        if (quote != null && quote['05. price'] != null) {
          return Decimal.parse(quote['05. price']);
        }
      }
    } catch (e) {
      print('Error fetching stock price: $e');
    }
    return null;
  }

  // ดึงราคาคริปโต
  Future<Decimal?> getCryptoPrice(String symbol) async {
    try {
      final url = Uri.parse(
          '$_coinGeckoBaseUrl/simple/price?ids=$symbol&vs_currencies=usd'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data[symbol] != null && data[symbol]['usd'] != null) {
          return Decimal.parse(data[symbol]['usd'].toString());
        }
      }
    } catch (e) {
      print('Error fetching crypto price: $e');
    }
    return null;
  }

  // ค้นหาหุ้น
  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    try {
      final url = Uri.parse(
          '$_alphaVantageBaseUrl?function=SYMBOL_SEARCH&keywords=$query&apikey=${AppConstants.alphaVantageApiKey}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final matches = data['bestMatches'] as List<dynamic>?;

        if (matches != null) {
          return matches.map((match) => {
            'symbol': match['1. symbol'] ?? '',
            'name': match['2. name'] ?? '',
          }).toList();
        }
      }
    } catch (e) {
      print('Error searching stocks: $e');
    }
    return [];
  }

  // ค้นหาคริปโต
  Future<List<Map<String, dynamic>>> searchCryptos(String query) async {
    try {
      final url = Uri.parse('$_coinGeckoBaseUrl/search?query=$query');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coins = data['coins'] as List<dynamic>?;

        if (coins != null) {
          return coins.take(10).map((coin) => {
            'symbol': coin['symbol'] ?? '',
            'name': coin['name'] ?? '',
            'id': coin['id'] ?? '',
          }).toList();
        }
      }
    } catch (e) {
      print('Error searching cryptos: $e');
    }
    return [];
  }

  // อัพเดทราคาปัจจุบันทั้งหมด
  Future<List<Investment>> updateAllPrices(List<Investment> investments) async {
    final updatedInvestments = <Investment>[];

    for (final investment in investments) {
      Decimal? newPrice;

      if (investment.type == InvestmentType.stock) {
        newPrice = await getStockPrice(investment.symbol);
      } else {
        newPrice = await getCryptoPrice(investment.symbol);
      }

      if (newPrice != null) {
        updatedInvestments.add(investment.copyWith(currentPrice: newPrice));
      } else {
        updatedInvestments.add(investment);
      }
    }

    return updatedInvestments;
  }
}
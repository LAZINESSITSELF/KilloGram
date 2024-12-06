import 'package:flutter/material.dart';

class CurrencyConversionPage extends StatefulWidget {
  const CurrencyConversionPage({Key? key}) : super(key: key);

  @override
  State<CurrencyConversionPage> createState() => _CurrencyConversionPageState();
}

class _CurrencyConversionPageState extends State<CurrencyConversionPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double _convertedAmount = 0.0;

  final Map<String, double> exchangeRates = {
    'USD': 1.0, // Base
    'EUR': 0.94, // USD to EUR
    'JPY': 141.0, // USD to JPY
    'IDR': 15000.0, // USD to IDR
    'GBP': 0.78, // USD to GBP
  };

  void _convertCurrency() {
    double? amount = double.tryParse(_amountController.text);
    if (amount != null) {
      setState(() {
        _convertedAmount = amount *
            (exchangeRates[_toCurrency]! / exchangeRates[_fromCurrency]!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Conversion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _fromCurrency,
                  items: exchangeRates.keys
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                    });
                  },
                ),
                Icon(Icons.arrow_forward),
                DropdownButton<String>(
                  value: _toCurrency,
                  items: exchangeRates.keys
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 16),
            Text(
              'Converted Amount: ${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

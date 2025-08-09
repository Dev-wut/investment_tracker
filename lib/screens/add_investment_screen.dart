import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_provider.dart';
import '../models/investment.dart';
import '../utils/helpers.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _notesController = TextEditingController();

  InvestmentType _selectedType = InvestmentType.stock;
  DateTime _purchaseDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<InvestmentProvider>();

    setState(() => _isLoading = true);

    try {
      final investment = Investment(
        id: generateId(),
        symbol: _symbolController.text.toUpperCase(),
        name: _nameController.text,
        type: _selectedType,
        quantity: Decimal.parse(_quantityController.text),
        buyPrice: Decimal.parse(_buyPriceController.text),
        currentPrice: Decimal.parse(_buyPriceController.text),
        purchaseDate: _purchaseDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      provider.addInvestment(investment);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่มการลงทุนเรียบร้อยแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มการลงทุน'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInvestment,
            child: Text('บันทึก'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ประเภทการลงทุน',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<InvestmentType>(
                            title: Text('หุ้น'),
                            value: InvestmentType.stock,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<InvestmentType>(
                            title: Text('คริปโต'),
                            value: InvestmentType.crypto,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() => _selectedType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _symbolController,
                      decoration: InputDecoration(
                        labelText: 'Symbol',
                        hintText: _selectedType == InvestmentType.stock ? 'เช่น AAPL' : 'เช่น BTC',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอก Symbol';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อ',
                        hintText: 'ชื่อบริษัทหรือเหรียญ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่อ';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'จำนวน',
                              hintText: '0.0',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกจำนวน';
                              }
                              try {
                                final quantity = Decimal.parse(value);
                                if (quantity <= Decimal.zero) {
                                  return 'จำนวนต้องมากกว่า 0';
                                }
                              } catch (e) {
                                return 'จำนวนไม่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _buyPriceController,
                            decoration: InputDecoration(
                              labelText: 'ราคาซื้อ',
                              hintText: '0.00',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกราคา';
                              }
                              try {
                                final price = Decimal.parse(value);
                                if (price <= Decimal.zero) {
                                  return 'ราคาต้องมากกว่า 0';
                                }
                              } catch (e) {
                                return 'ราคาไม่ถูกต้อง';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _purchaseDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _purchaseDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'วันที่ซื้อ',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(formatDate(_purchaseDate)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'หมายเหตุ (ไม่บังคับ)',
                        hintText: 'บันทึกเพิ่มเติม',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
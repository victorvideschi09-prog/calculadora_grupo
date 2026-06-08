import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<CalculatorModel>(
      create: (context) => CalculatorModel(),
      child: const CalculatorApp(),
    ),
  );
}

class CalculatorModel extends ChangeNotifier {
  String _display = '0';
  String _history = '';
  double _firstNumber = 0;
  String _operation = '';
  bool _shouldResetDisplay = false; // Flag para limpar a tela após uma operação

  String get display => _display;
  String get history => _history;

  final NumberFormat _formatter = NumberFormat("#,###");

  String formatNumber(String value) {
    if (value == '0' || value.isEmpty || value == 'Erro') return value;
    
    // Evita quebrar se o número vier em notação científica ou formato inválido
    final cleanValue = value.replaceAll(',', '');
    final parts = cleanValue.split('.');
    
    final intValue = int.tryParse(parts[0]);
    if (intValue == null) return value;

    final formattedInteger = _formatter.format(intValue);
    
    // Se tiver parte decimal, mantém ela na formatação visual
    return parts.length > 1 ? '$formattedInteger.${parts[1]}' : formattedInteger;
  }

  void addNumber(String number) {
    if (_display == 'Erro') clear();

    // Se acabou de clicar em uma operação ou no '=', substitui o '0'
    if (_display == '0' || _shouldResetDisplay) {
      if (number == '0' && _display == '0') return; // Evita '00'
      _display = number;
      _shouldResetDisplay = false;
    } else {
      _display += number;
    }
    notifyListeners();
  }

  void backspace() {
    if (_display == 'Erro') {
      clear();
      return;
    }
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
    notifyListeners();
  }

  void setOperation(String op) {
    if (_display == 'Erro') return;
    
    _firstNumber = double.tryParse(_display) ?? 0;
    _operation = op;
    _history = '${formatNumber(_display)} $op';
    _shouldResetDisplay = true; // Avisa que o próximo número digitado limpa o display anterior
    notifyListeners();
  }

  void toggleSign() {
    if (_display != '0' && _display != 'Erro') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
      notifyListeners();
    }
  }

  void calculate() {
    if (_operation.isEmpty || _display == 'Erro') return;

    double secondNumber = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _firstNumber + secondNumber;
        break;
      case '-':
        result = _firstNumber - secondNumber;
        break;
      case '×':
        result = _firstNumber * secondNumber;
        break;
      case '÷':
        if (secondNumber == 0) {
          _display = 'Erro';
          _history = '${formatNumber(_firstNumber.toString())} ÷ 0 =';
          _operation = '';
          notifyListeners();
          return;
        }
        result = _firstNumber / secondNumber;
        break;
      default:
        return;
    }

    // Histórico corrigido para não cortar números decimais com split parcial
    _history = '${formatNumber(_firstNumber.toString())} $_operation ${formatNumber(secondNumber.toString())} =';
    
    // Formata o resultado removendo o .0 desnecessário se for inteiro
    _display = result.remainder(1) == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
    _operation = '';
    _shouldResetDisplay = true;
    notifyListeners();
  }

  void clear() {
    _display = '0';
    _history = '';
    _firstNumber = 0;
    _operation = '';
    _shouldResetDisplay = false;
    notifyListeners();
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CalculatorModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  model.history,
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(bottom: 24, top: 10),
                child: Text(
                  model.formatNumber(model.display),
                  style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Row(
                children: [
                  _CalculatorButton(
                    'AC',
                    color: const Color(0xFF4A4A4C),
                    onTap: model.clear,
                  ),
                  _CalculatorButton(
                    '+/-',
                    color: const Color(0xFF4A4A4C),
                    onTap: model.toggleSign,
                  ),
                  _CalculatorButton(
                    '',
                    icon: Icons.backspace_outlined,
                    color: Colors.orange,
                    onTap: model.backspace,
                  ),
                  _CalculatorButton(
                    '÷',
                    color: Colors.orange,
                    onTap: () => model.setOperation('÷'),
                  ),
                ],
              ),
              Row(
                children: [
                  _CalculatorButton('7', onTap: () => model.addNumber('7')),
                  _CalculatorButton('8', onTap: () => model.addNumber('8')),
                  _CalculatorButton('9', onTap: () => model.addNumber('9')),
                  _CalculatorButton(
                    '×',
                    color: Colors.orange,
                    onTap: () => model.setOperation('×'),
                  ),
                ],
              ),
              Row(
                children: [
                  _CalculatorButton('4', onTap: () => model.addNumber('4')),
                  _CalculatorButton('5', onTap: () => model.addNumber('5')),
                  _CalculatorButton('6', onTap: () => model.addNumber('6')),
                  _CalculatorButton(
                    '-',
                    color: Colors.orange,
                    onTap: () => model.setOperation('-'),
                  ),
                ],
              ),
              Row(
                children: [
                  _CalculatorButton('1', onTap: () => model.addNumber('1')),
                  _CalculatorButton('2', onTap: () => model.addNumber('2')),
                  _CalculatorButton('3', onTap: () => model.addNumber('3')),
                  _CalculatorButton(
                    '+',
                    color: Colors.orange,
                    onTap: () => model.setOperation('+'),
                  ),
                ],
              ),
              Row(
                children: [
                  _CalculatorButton(
                    '0',
                    flex: 2,
                    onTap: () => model.addNumber('0'),
                  ),
                  _CalculatorButton(
                    '=',
                    color: Colors.orange,
                    onTap: model.calculate,
                    flex: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  final int flex;
  final IconData? icon;

  const _CalculatorButton(
    this.text, {
    this.color = const Color(0xFF2C2C2E),
    required this.onTap,
    this.flex = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: onTap,
          child: icon != null
              ? Icon(icon, size: 28, color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

// lib/pages/driver_earnings_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Utils/Color.dart';

class EarningsTimeseries {
  final DateTime date;
  final double earnings;
  EarningsTimeseries({required this.date, required this.earnings});
}

class TransactionItem {
  final String id;
  final String title;
  final DateTime date;
  double amount;
  String status; // Paid, Pending, Fee
  final String note;

  TransactionItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'amount': amount,
    'status': status,
    'note': note,
  };
}

enum RangePeriod { today, week, month, custom }

class DriverEarningsPage extends StatefulWidget {
  const DriverEarningsPage({Key? key}) : super(key: key);

  @override
  State<DriverEarningsPage> createState() => _DriverEarningsPageState();
}

class _DriverEarningsPageState extends State<DriverEarningsPage> {
  // --- In-page mock data ---------------------------------------------------
  RangePeriod _selectedRange = RangePeriod.week;

  double totalEarnings = 1250.75;
  double weekEarnings = 350.25;
  double monthEarnings = 800.50;
  double availableForPayout = 200.00;

  // timeseries 7 days example
  late List<EarningsTimeseries> _timeseries;

  // transactions mock
  late List<TransactionItem> _transactions;

  // filter/search/sort state
  String _searchQuery = '';
  String _transactionsSort = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initMocks();
  }

  void _initMocks() {
    final now = DateTime.now();
    _timeseries = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final value = (50 + (i * 20) + (i % 2 == 0 ? 25 : -10)).toDouble();
      return EarningsTimeseries(date: d, earnings: value);
    });

    _transactions = [
      TransactionItem(id: 'T1', title: 'Payout to Bank', date: DateTime.now().subtract(const Duration(days: 1)), amount: 50.00, status: 'Paid'),
      TransactionItem(id: 'T2', title: 'Payout to Bank', date: DateTime.now().subtract(const Duration(days: 2)), amount: 75.00, status: 'Pending'),
      TransactionItem(id: 'T3', title: 'Adjustment', date: DateTime.now().subtract(const Duration(days: 3)), amount: -5.00, status: 'Fee', note: 'Platform fee'),
      TransactionItem(id: 'T4', title: 'Payout to Bank', date: DateTime.now().subtract(const Duration(days: 4)), amount: 80.00, status: 'Paid'),
    ];
  }

  // --- Simulated reload ---------------------------------------------------
  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    // simulate small changes
    setState(() {
      weekEarnings += 2.0;
      totalEarnings += 2.0;
      availableForPayout += 0.5;
      // push a small timeseries bump
      final last = _timeseries.last.earnings + 6;
      _timeseries = [..._timeseries.sublist(1), EarningsTimeseries(date: DateTime.now(), earnings: last)];
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed')));
  }

  // --- CSV export (returns string) ----------------------------------------
  // Implemented locally (no external package)
  String _escapeCsvField(String input) {
    if (input.contains(',') || input.contains('"') || input.contains('\n')) {
      final escaped = input.replaceAll('"', '""');
      return '"$escaped"';
    }
    return input;
  }

  String _transactionsToCsv(List<TransactionItem> items) {
    final sb = StringBuffer();
    // header
    sb.writeln('id,title,date,amount,status,note');
    for (final t in items) {
      final id = _escapeCsvField(t.id);
      final title = _escapeCsvField(t.title);
      final date = _escapeCsvField(t.date.toIso8601String());
      final amount = t.amount.toStringAsFixed(2);
      final status = _escapeCsvField(t.status);
      final note = _escapeCsvField(t.note);
      sb.writeln('$id,$title,$date,$amount,$status,$note');
    }
    return sb.toString();
  }

  Future<void> _exportCsv() async {
    final csv = _transactionsToCsv(_transactions);
    // For now show as SnackBar; later save to file and share
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV created (preview in console)')));
    // print for dev
    // ignore: avoid_print
    print(csv);
  }

  // --- Request payout flow ------------------------------------------------
  Future<void> _requestPayout() async {
    final amountController = TextEditingController(text: availableForPayout.toStringAsFixed(2));
    final result = await showDialog<double?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Payout'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
            ),
            const SizedBox(height: 8),
            const Text('Payout will be processed within 3-5 business days.'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(amountController.text) ?? 0.0;
                Navigator.pop(context, val);
              },
              child: const Text('Request'),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      // simulate adding a pending transaction and reduce available amount
      setState(() {
        _transactions.insert(
          0,
          TransactionItem(
            id: 'P${DateTime.now().millisecondsSinceEpoch}',
            title: 'Payout request',
            date: DateTime.now(),
            amount: result,
            status: 'Pending',
            note: 'Requested via app',
          ),
        );
        availableForPayout = (availableForPayout - result).clamp(0.0, double.infinity);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout requested')));
    }
  }

  // --- Transaction details sheet ------------------------------------------
  void _openTransactionDetails(TransactionItem t) {
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(t.date)}'),
            const SizedBox(height: 8),
            Text('Amount: \$${t.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Status: ${t.status}'),
            if (t.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${t.note}'),
            ],
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(
                onPressed: () {
                  // example of an actionable button
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help requested for transaction')));
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    // demo: mark pending -> Paid
                    if (t.status == 'Pending') {
                      t.status = 'Paid';
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Mark as Paid'),
              ),
            ])
          ]),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${_two(d.month)}-${_two(d.day)}';
  }

  String _two(int n) => n < 10 ? '0$n' : '$n';

  // --- Transactions list helpers -----------------------------------------
  List<TransactionItem> _getFilteredSortedTransactions() {
    var list = _transactions.where((t) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) || t.id.toLowerCase().contains(q) || t.status.toLowerCase().contains(q);
    }).toList();

    switch (_transactionsSort) {
      case 'date_asc':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount_asc':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      default:
        list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  // --- tiny sparkline painter ----------------------------------------------
  Widget _buildSparkline(List<EarningsTimeseries> series, {Color? color}) {
    return SizedBox(height: 64, width: 160, child: CustomPaint(painter: _SparklinePainter(series, color ?? AppColors.primary)));
  }

  @override
  Widget build(BuildContext context) {
    final txs = _getFilteredSortedTransactions();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: AppColors.textLight,
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text('Earnings', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            color: AppColors.textLight,
            onPressed: _exportCsv,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // Range selector
              _buildRangeSelector(),

              const SizedBox(height: 12),

              // Summary cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(child: _summaryCard('Total Earnings', '\$${totalEarnings.toStringAsFixed(2)}', '+2.5%')),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryCard('This Week', '\$${weekEarnings.toStringAsFixed(2)}', '-1.2%', isNegative: true)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(child: _summaryCard('This Month', '\$${monthEarnings.toStringAsFixed(2)}', '+3.8%')),
                  const SizedBox(width: 8),
                  // Expanded(child: _summaryCard('Available', '\$${availableForPayout.toStringAsFixed(2)}', 'no change', neutral: true, actionLabel: 'Request', action: _requestPayout)),
                ],
              ),

              const SizedBox(height: 16),

              // Chart
              _buildChartCard(),

              const SizedBox(height: 16),

              // Breakdown chips
              _buildBreakdownChips(),

              const SizedBox(height: 16),

              // Recent transactions header
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(children: [
                  IconButton(
                    onPressed: () => setState(() {
                      // toggle sort
                      _transactionsSort = _transactionsSort == 'date_desc' ? 'amount_desc' : 'date_desc';
                    }),
                    icon: const Icon(Icons.sort),
                  ),
                  IconButton(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.share),
                  ),
                ]),
              ]),

              // Search field
              TextField(
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search transactions', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),

              const SizedBox(height: 12),

              // Transactions list
              if (txs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: Text('No transactions', style: TextStyle(color: AppColors.subtleLight))),
                )
              else
                ...txs.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _transactionTile(t))).toList(),
            ],
          ),
        ),
      ),

      // Support FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _openSupport,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.support_agent),
      ),
    );
  }

  // --- UI pieces ----------------------------------------------------------
  Widget _buildRangeSelector() {
    Widget _btn(RangePeriod r, String label) {
      final active = _selectedRange == r;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedRange = r),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.backgroundLight : AppColors.cardLight.withOpacity(0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: active ? AppColors.primary : AppColors.subtleLight, fontWeight: FontWeight.w600)),
          ),
        ),
      );
    }

    return Row(children: [
      _btn(RangePeriod.today, 'Today'),
      const SizedBox(width: 8),
      _btn(RangePeriod.week, 'Week'),
      const SizedBox(width: 8),
      _btn(RangePeriod.month, 'Month'),
      const SizedBox(width: 8),
      _btn(RangePeriod.custom, 'Custom'),
    ]);
  }

  Widget _summaryCard(String title, String value, String delta, {bool isNegative = false, bool neutral = false, String? actionLabel, VoidCallback? action}) {
    final Color deltaColor = neutral ? AppColors.subtleLight : (isNegative ? Colors.red : Colors.green);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(isNegative ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: deltaColor),
              const SizedBox(width: 6),
              Text(delta, style: TextStyle(color: deltaColor)),
            ]),
            if (actionLabel != null && action != null) const SizedBox(height: 8),
            if (actionLabel != null && action != null)
              SizedBox(
                height: 32,
                child: OutlinedButton(onPressed: action, child: Text(actionLabel)),
              )
          ]),
        ),
        const SizedBox(width: 8),
        _buildSparkline(_timeseries.take(7).toList()),
      ]),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Earnings Over Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: _LargeAreaChart(series: _timeseries)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          Text('Mon', style: TextStyle(fontSize: 12)),
          Text('Tue', style: TextStyle(fontSize: 12)),
          Text('Wed', style: TextStyle(fontSize: 12)),
          Text('Thu', style: TextStyle(fontSize: 12)),
          Text('Fri', style: TextStyle(fontSize: 12)),
          Text('Sat', style: TextStyle(fontSize: 12)),
          Text('Sun', style: TextStyle(fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _buildBreakdownChips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        _chip('Base fare', AppColors.primary.withOpacity(0.12), AppColors.primary),
        _chip('Tips', Colors.green.withOpacity(0.12), Colors.green),
        _chip('Bonuses', Colors.blue.withOpacity(0.12), Colors.blue),
        _chip('Adjustments', Colors.orange.withOpacity(0.12), Colors.orange),
        _chip('Fees', Colors.grey.withOpacity(0.12), Colors.grey),
      ]),
    );
  }

  Widget _chip(String label, Color bg, Color color) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color)));
  }

  Widget _transactionTile(TransactionItem t) {
    final Color amountColor = t.amount >= 0 ? Colors.green : Colors.red;
    final String formatted = '\$${t.amount.toStringAsFixed(2)}';
    return InkWell(
      onTap: () => _openTransactionDetails(t),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(_formatDate(t.date), style: TextStyle(color: AppColors.subtleLight)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(formatted, style: TextStyle(fontWeight: FontWeight.bold, color: amountColor)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: _statusColorBg(t.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(t.status, style: TextStyle(color: _statusColorText(t.status), fontSize: 12, fontWeight: FontWeight.w600)),
            )
          ]),
        ]),
      ),
    );
  }

  Color _statusColorBg(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade50;
      case 'Pending':
        return Colors.yellow.shade50;
      case 'Fee':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _statusColorText(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade700;
      case 'Pending':
        return Colors.orange.shade700;
      case 'Fee':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _bottomNavItem(IconData icon, String label, bool active) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? AppColors.primary : AppColors.subtleLight),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.subtleLight)),
    ]);
  }

  void _openSupport() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Support'),
        content: const Text('Open support chat or call here.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

// ---------------- small custom painters / widgets --------------------------
class _SparklinePainter extends CustomPainter {
  final List<EarningsTimeseries> series;
  final Color color;
  _SparklinePainter(this.series, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;
    final max = series.map((s) => s.earnings).reduce((a, b) => a > b ? a : b);
    final min = series.map((s) => s.earnings).reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1 : (max - min);
    final stepX = size.width / (series.length - 1);
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = stepX * i;
      final y = size.height - ((series[i].earnings - min) / range) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.series != series || old.color != color;
}

// Large chart placeholder as in the HTML (area + line)
class _LargeAreaChart extends StatelessWidget {
  final List<EarningsTimeseries> series;
  const _LargeAreaChart({Key? key, required this.series}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LargeAreaChartPainter(series, AppColors.primary),
      size: Size.infinite,
    );
  }
}

class _LargeAreaChartPainter extends CustomPainter {
  final List<EarningsTimeseries> series;
  final Color color;
  _LargeAreaChartPainter(this.series, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final paintArea = Paint()
      ..shader = LinearGradient(colors: [color.withOpacity(0.25), color.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    if (series.isEmpty) return;
    final max = series.map((s) => s.earnings).reduce((a, b) => a > b ? a : b);
    final min = series.map((s) => s.earnings).reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1 : (max - min);
    final stepX = size.width / (series.length - 1);

    final path = Path();
    final areaPath = Path();

    for (var i = 0; i < series.length; i++) {
      final x = stepX * i;
      final y = size.height - ((series[i].earnings - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }
    // close the area path to bottom right and bottom left
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, paintArea);
    canvas.drawPath(path, paintLine);

    // horizontal dashed lines
    final dashPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      const dashWidth = 6.0;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), dashPaint);
        startX += dashWidth * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LargeAreaChartPainter old) => old.series != series || old.color != color;
}

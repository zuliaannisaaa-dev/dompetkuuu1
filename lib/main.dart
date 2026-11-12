import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DompetkuApp());

class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFD96B91);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dompetku',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: pink, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFFFF8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF8FA),
          foregroundColor: Color(0xFF30252A),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0E3E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0E3E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: pink, width: 1.5),
          ),
        ),
      ),
      home: const DompetkuHome(),
    );
  }
}

class Transaction {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

class DompetkuHome extends StatefulWidget {
  const DompetkuHome({super.key});

  @override
  State<DompetkuHome> createState() => _DompetkuHomeState();
}

class _DompetkuHomeState extends State<DompetkuHome> {
  final List<Transaction> transactions = [
    Transaction(title: 'Uang saku bulanan', category: 'Pemasukan', amount: 1500000, date: DateTime.now(), isIncome: true),
    Transaction(title: 'Makan siang', category: 'Makanan', amount: 25000, date: DateTime.now(), isIncome: false),
    Transaction(title: 'Ojek online', category: 'Transportasi', amount: 18000, date: DateTime.now().subtract(const Duration(days: 1)), isIncome: false),
    Transaction(title: 'Buku kuliah', category: 'Pendidikan', amount: 65000, date: DateTime.now().subtract(const Duration(days: 2)), isIncome: false),
  ];

  int selectedTab = 0;

  double get totalIncome => transactions.where((t) => t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
  double get totalExpense => transactions.where((t) => !t.isIncome).fold<double>(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpense;

  String rupiah(double value) {
    final s = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return 'Rp${buffer.toString()}';
  }

  String dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> addTransaction() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result != null) {
      setState(() => transactions.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
      );
    }
  }

  void openDetail(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(
          transaction: transaction,
          moneyFormatter: rupiah,
          dateFormatter: dateLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _buildTransactionList(),
      _buildCategories(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: const Color(0xFFF9E2EA), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFD96B91)),
            ),
            const SizedBox(width: 10),
            const Text('Dompetku', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifikasi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: selectedTab, children: pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTransaction,
        backgroundColor: const Color(0xFFD96B91),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF9E2EA),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Kategori'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final latest = transactions.take(4).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        const Text('Halo, selamat datang! 👋', style: TextStyle(fontSize: 15, color: Color(0xFF8A7A81))),
        const SizedBox(height: 5),
        const Text('Atur keuanganmu hari ini.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF30252A))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFD96B91), Color(0xFFB94F78)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFFD96B91).withOpacity(.22), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Text(rupiah(balance), style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _moneyInfo(Icons.arrow_downward_rounded, 'Pemasukan', rupiah(totalIncome))),
              Container(width: 1, height: 42, color: Colors.white30),
              const SizedBox(width: 18),
              Expanded(child: _moneyInfo(Icons.arrow_upward_rounded, 'Pengeluaran', rupiah(totalExpense))),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Ringkasan keuangan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _summaryCard('Pemasukan', rupiah(totalIncome), Icons.trending_up, const Color(0xFFE6F4EC), const Color(0xFF39865B))),
          const SizedBox(width: 12),
          Expanded(child: _summaryCard('Pengeluaran', rupiah(totalExpense), Icons.trending_down, const Color(0xFFFCE8ED), const Color(0xFFC45B7C))),
        ]),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Transaksi terbaru', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          TextButton(onPressed: () => setState(() => selectedTab = 1), child: const Text('Lihat semua')),
        ]),
        const SizedBox(height: 4),
        if (latest.isEmpty)
          const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Belum ada transaksi.')))
        else
          ...latest.map((t) => _transactionTile(t)),
      ],
    );
  }

  Widget _moneyInfo(IconData icon, String label, String value) => Row(children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 18)),
    const SizedBox(width: 9),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 3),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
    ])),
  ]);

  Widget _summaryCard(String title, String value, IconData icon, Color bg, Color fg) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF1E6EA))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: fg, size: 18)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: Color(0xFF8A7A81), fontSize: 12)),
      const SizedBox(height: 4),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
    ]),
  );

  Widget _buildTransactionList() {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Riwayat transaksi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Lihat pemasukan dan pengeluaranmu',
                    style: TextStyle(color: Color(0xFF8A7A81))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9E2EA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const TabBar(
                labelColor: Color(0xFF9F3F65),
                unselectedLabelColor: Color(0xFF8A7A81),
                indicatorColor: Color(0xFFD96B91),
                tabs: [
                  Tab(text: 'Semua'),
                  Tab(text: 'Pemasukan'),
                  Tab(text: 'Pengeluaran'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                _transactionTab(transactions),
                _transactionTab(transactions.where((t) => t.isIncome).toList()),
                _transactionTab(transactions.where((t) => !t.isIncome).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTab(List<Transaction> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada transaksi.',
          style: TextStyle(color: Color(0xFF8A7A81)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _transactionTile(items[index]),
      ),
    );
  }

  Widget _transactionTile(Transaction t) {
    final color = t.isIncome ? const Color(0xFF39865B) : const Color(0xFFC45B7C);
    final icon = categoryIcon(t.category);
    return InkWell(
      onTap: () => openDetail(t),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFF1E6EA))),
        child: Row(children: [
          Container(width: 45, height: 45, decoration: BoxDecoration(color: t.isIncome ? const Color(0xFFE6F4EC) : const Color(0xFFFCE8ED), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${t.category} • ${dateLabel(t.date)}', style: const TextStyle(fontSize: 11, color: Color(0xFF998B91))),
          ])),
          const SizedBox(width: 8),
          Text('${t.isIncome ? '+' : '-'}${rupiah(t.amount)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
        ]),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      ('Makanan', Icons.restaurant_rounded, '0xFFFCE8ED', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300'),
      ('Transportasi', Icons.directions_car_rounded, '0xFFE8F0FC', 'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=300'),
      ('Pendidikan', Icons.menu_book_rounded, '0xFFEDE8FC', 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=300'),
      ('Hiburan', Icons.movie_rounded, '0xFFFFF1DD', 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=300'),
      ('Belanja', Icons.shopping_bag_rounded, '0xFFE6F4EC', 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=300'),
      ('Lainnya', Icons.more_horiz_rounded, '0xFFF1E6EA', 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=300'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Text('Kategori', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('Kelompokkan pengeluaran agar lebih terkontrol.', style: TextStyle(color: Color(0xFF8A7A81))),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .95),
          itemBuilder: (context, index) {
            final c = categories[index];
            final total = transactions.where((t) => !t.isIncome && t.category == c.$1).fold<double>(0, (sum, t) => sum + t.amount);
            return Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF1E6EA))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 78,
                    width: double.infinity,
                    child: Image.network(c.$4, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF9E2EA), child: Icon(c.$2, color: const Color(0xFFD96B91), size: 32))),
                  ),
                ),
                const Spacer(),
                Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(rupiah(total), style: const TextStyle(fontSize: 12, color: Color(0xFF8A7A81))),
              ]),
            );
          },
        ),
      ],
    );
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Makanan': return Icons.restaurant_rounded;
      case 'Transportasi': return Icons.directions_car_rounded;
      case 'Pendidikan': return Icons.menu_book_rounded;
      case 'Hiburan': return Icons.movie_rounded;
      case 'Belanja': return Icons.shopping_bag_rounded;
      case 'Pemasukan': return Icons.account_balance_wallet_rounded;
      default: return Icons.category_rounded;
    }
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String type = 'Pengeluaran';
  String category = 'Makanan';
  DateTime date = DateTime.now();

  final expenseCategories = ['Makanan', 'Transportasi', 'Pendidikan', 'Hiburan', 'Belanja', 'Lainnya'];

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => date = picked);
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final amount = double.parse(amountController.text.replaceAll('.', '').replaceAll(',', '.'));
    Navigator.pop(
      context,
      Transaction(
        title: titleController.text.trim(),
        category: type == 'Pemasukan' ? 'Pemasukan' : category,
        amount: amount,
        date: date,
        isIncome: type == 'Pemasukan',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Catat transaksi baru', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Isi informasi transaksi dengan benar.', style: TextStyle(color: Color(0xFF8A7A81))),
            const SizedBox(height: 22),
            const Text('Jenis transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 9),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Pengeluaran', label: Text('Pengeluaran'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: 'Pemasukan', label: Text('Pemasukan'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {type},
              onSelectionChanged: (value) => setState(() {
                type = value.first;
                if (type == 'Pemasukan') category = 'Pemasukan';
                else category = 'Makanan';
              }),
            ),
            const SizedBox(height: 18),
            const Text('Nama transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Contoh: Makan siang'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nama transaksi wajib diisi' : null,
            ),
            const SizedBox(height: 18),
            const Text('Nominal (Rp)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(hintText: 'Contoh: 25000', prefixText: 'Rp '),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                final parsed = double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Masukkan nominal yang valid';
                return null;
              },
            ),
            if (type == 'Pengeluaran') ...[
              const SizedBox(height: 18),
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(),
                items: expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v ?? 'Makanan'),
              ),
            ],
            const SizedBox(height: 18),
            const Text('Tanggal transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: chooseDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), foregroundColor: const Color(0xFFB94F78)),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: save,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD96B91), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Simpan Transaksi', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;
  final String Function(double) moneyFormatter;
  final String Function(DateTime) dateFormatter;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.moneyFormatter,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? const Color(0xFF39865B) : const Color(0xFFC45B7C);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 24),
          CircleAvatar(radius: 38, backgroundColor: transaction.isIncome ? const Color(0xFFE6F4EC) : const Color(0xFFFCE8ED),
            child: Icon(transaction.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 34)),
          const SizedBox(height: 16),
          Text(transaction.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${transaction.isIncome ? '+' : '-'}${moneyFormatter(transaction.amount)}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 28),
          _detailRow('Jenis transaksi', transaction.isIncome ? 'Pemasukan' : 'Pengeluaran'),
          _detailRow('Kategori', transaction.category),
          _detailRow('Tanggal', dateFormatter(transaction.date)),
          const Spacer(),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali'))),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1E6EA)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF8A7A81))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ]),
  );
}
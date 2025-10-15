// // lib/pages/orders_history_page.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// import '../../Models/order_model.dart';
//
//
// class OrdersHistoryPage extends StatefulWidget {
//   const OrdersHistoryPage({super.key});
//
//   @override
//   State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
// }
//
// class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
//   final _service = OrdersService.instance;
//
//   // pagination & filter
//   int _page = 1;
//   final int _perPage = 20;
//   bool _isLoading = false;
//   bool _isRefreshing = false;
//   bool _hasMore = true;
//   String? _statusFilter;
//   String? _searchQuery;
//
//   final List<OrderModel> _orders = [];
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//
//   final DateFormat _dateFmt = DateFormat.yMMMd().add_jm();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFirstPage();
//
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
//         if (!_isLoading && _hasMore) _loadNextPage();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadFirstPage() async {
//     setState(() {
//       _isRefreshing = true;
//       _page = 1;
//       _hasMore = true;
//     });
//     try {
//       final res = await _service.fetchOrders(page: 1, perPage: _perPage, query: _searchQuery, status: _statusFilter);
//       setState(() {
//         _orders
//           ..clear()
//           ..addAll(res.items);
//         _hasMore = res.items.length >= _perPage && (res.items.length + (res.page - 1) * res.perPage) < res.total;
//       });
//     } catch (e) {
//       _showSnack('Failed to load orders: $e');
//     } finally {
//       setState(() => _isRefreshing = false);
//     }
//   }
//
//   Future<void> _loadNextPage() async {
//     if (!_hasMore) return;
//     setState(() => _isLoading = true);
//     final next = _page + 1;
//     try {
//       final res = await _service.fetchOrders(page: next, perPage: _perPage, query: _searchQuery, status: _statusFilter);
//       setState(() {
//         _page = next;
//         _orders.addAll(res.items);
//         _hasMore = res.items.length >= _perPage && (_orders.length) < res.total;
//       });
//     } catch (e) {
//       _showSnack('Failed to load more orders: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showSnack(String text) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }
//
//   void _onSearchSubmitted(String q) {
//     _searchQuery = q.trim().isEmpty ? null : q.trim();
//     _loadFirstPage();
//   }
//
//   void _onFilterStatus(String? status) {
//     _statusFilter = status;
//     _loadFirstPage();
//   }
//
//   // Order detail bottom sheet
//   void _openOrderDetail(OrderModel o) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(top: 18, left: 18, right: 18, bottom: MediaQuery.of(ctx).viewInsets.bottom + 18),
//           child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Text('Order ${o.id}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700))),
//               Text(_dateFmt.format(o.createdAt), style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
//             ]),
//             const SizedBox(height: 12),
//             Text('Customer: ${o.customerName}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Text('Pickup: ${o.pickupAddress}', style: GoogleFonts.inter(color: Colors.grey.shade700)),
//             const SizedBox(height: 6),
//             Text('Delivery: ${o.deliveryAddress}', style: GoogleFonts.inter(color: Colors.grey.shade700)),
//             const SizedBox(height: 10),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Text('Items: ${o.itemsCount}', style: GoogleFonts.inter()),
//               Text('Amount: ₹${o.amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
//             ]),
//             const SizedBox(height: 12),
//             Chip(label: Text(o.status.toUpperCase()), backgroundColor: _statusColor(o.status).withOpacity(0.12), labelStyle: TextStyle(color: _statusColor(o.status))),
//             const SizedBox(height: 16),
//             Row(children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                     _showSnack('Reorder ${o.id} (stub)');
//                   },
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Reorder'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                     _showSnack('Contact ${o.customerName} (stub)');
//                   },
//                   icon: const Icon(Icons.phone),
//                   label: const Text('Contact'),
//                 ),
//               ),
//             ]),
//           ]),
//         );
//       },
//     );
//   }
//
//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.redAccent;
//       case 'in_transit':
//       case 'on_way':
//         return Colors.orange;
//       default:
//         return Colors.blueGrey;
//     }
//   }
//
//   Widget _buildOrderTile(OrderModel o) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       onTap: () => _openOrderDetail(o),
//       leading: CircleAvatar(
//         backgroundColor: Colors.grey.shade100,
//         child: Text(o.customerName.isNotEmpty ? o.customerName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.black87)),
//       ),
//       title: Text('Order ${o.id}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
//       subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const SizedBox(height: 4),
//         Text('${o.customerName} • ${o.itemsCount} items', style: GoogleFonts.inter(fontSize: 13)),
//         Text(o.deliveryAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
//       ]),
//       trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
//         Text('₹${o.amount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
//         const SizedBox(height: 6),
//         Chip(label: Text(o.status, style: const TextStyle(fontSize: 12)), backgroundColor: _statusColor(o.status).withOpacity(0.12), visualDensity: VisualDensity.compact),
//       ]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Past Orders', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
//         actions: [
//           IconButton(
//             tooltip: 'Filter',
//             onPressed: () => _openFilterSheet(),
//             icon: const Icon(Icons.filter_list),
//           )
//         ],
//       ),
//       body: Column(children: [
//         // Search
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           child: Row(children: [
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 textInputAction: TextInputAction.search,
//                 onSubmitted: _onSearchSubmitted,
//                 decoration: InputDecoration(
//                   hintText: 'Search by order id or customer',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(onPressed: () {
//                     _searchController.clear();
//                     _onSearchSubmitted('');
//                   }, icon: const Icon(Icons.close)),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                   filled: true,
//                 ),
//               ),
//             ),
//           ]),
//         ),
//
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _loadFirstPage,
//             child: _orders.isEmpty && !_isRefreshing
//                 ? ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               children: [
//                 SizedBox(height: 60),
//                 Center(child: Text('No orders yet', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey))),
//                 SizedBox(height: 400),
//               ],
//             )
//                 : ListView.separated(
//               controller: _scrollController,
//               padding: const EdgeInsets.only(bottom: 24),
//               itemCount: _orders.length + (_hasMore ? 1 : 0),
//               separatorBuilder: (_, __) => const Divider(height: 1, indent: 12, endIndent: 12),
//               itemBuilder: (ctx, i) {
//                 if (i < _orders.length) {
//                   final o = _orders[i];
//                   return _buildOrderTile(o);
//                 } else {
//                   // loading indicator for pagination
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ]),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // quick scroll to top
//           _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//         },
//         label: const Text('Top'),
//         icon: const Icon(Icons.arrow_upward),
//       ),
//     );
//   }
//
//   void _openFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) {
//         String? tmp = _statusFilter;
//         return StatefulBuilder(builder: (context, setSt) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Text('Filter Orders', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
//               const SizedBox(height: 12),
//               Wrap(spacing: 8, children: [
//                 ChoiceChip(
//                   label: const Text('All'),
//                   selected: tmp == null,
//                   onSelected: (_) => setSt(() => tmp = null),
//                 ),
//                 ChoiceChip(label: const Text('Delivered'), selected: tmp == 'delivered', onSelected: (_) => setSt(() => tmp = 'delivered')),
//                 ChoiceChip(label: const Text('In Transit'), selected: tmp == 'in_transit', onSelected: (_) => setSt(() => tmp = 'in_transit')),
//                 ChoiceChip(label: const Text('Cancelled'), selected: tmp == 'cancelled', onSelected: (_) => setSt(() => tmp = 'cancelled')),
//               ]),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(ctx).pop();
//                       _onFilterStatus(tmp);
//                     },
//                     child: const Text('Apply'),
//                   ),
//                 )
//               ])
//             ]),
//           );
//         });
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// --- 1. Data Models ---

class KpiData {
  final String title;
  final String value;
  final IconData icon;
  final String delta;

  KpiData({required this.title, required this.value, required this.icon, required this.delta});
}

class ActivityData {
  final String icon;
  final String title;
  final String subtitle;

  ActivityData({required this.icon, required this.title, required this.subtitle});
}

class StatData {
  final String label;
  final String value;

  StatData({required this.label, required this.value});
}

class LogisticsDashboardData {
  final String userName;
  final List<KpiData> kpis;
  final List<ActivityData> recentActivities;
  final List<StatData> quickStats;

  LogisticsDashboardData({
    required this.userName,
    required this.kpis,
    required this.recentActivities,
    required this.quickStats,
  });
}

// --- 2. Mock API Service ---

class LogisticsService {
  Future<LogisticsDashboardData> fetchDashboardData() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample Data
    final data = LogisticsDashboardData(
      userName: "Logistics Admin",
      kpis: [
        KpiData(
            title: "Active Deliveries",
            value: "52",
            icon: Icons.local_shipping_rounded,
            delta: "+5.1%"),
        KpiData(
            title: "Online Drivers",
            value: "14",
            icon: Icons.person_rounded,
            delta: "+3.0%"),
        KpiData(
            title: "On-Time Rate",
            value: "95.5%",
            icon: Icons.timer_rounded,
            delta: "+1.5%"),
        KpiData(
            title: "Revenue (Today)",
            value: "₹ 3,125",
            icon: Icons.attach_money_rounded,
            delta: "+7.2%"),
      ],
      recentActivities: [
        ActivityData(
            icon: "✅",
            title: "Delivered Order #SPG-1015",
            subtitle: "Driver: Maria • 2 min ago"),
        ActivityData(
            icon: "🚚",
            title: "Assigned Order #SPG-1016",
            subtitle: "Driver: Ken • 8 min ago"),
        ActivityData(
            icon: "⚠️",
            title: "Delay Reported (Engine)",
            subtitle: "Vehicle: V-201 • 15 min ago"),
      ],
      quickStats: [
        {"label": "Distance Today", "value": "450 km"},
        {"label": "Completed", "value": "240"},
        {"label": "Avg Delivery Time", "value": "25m"},
        {"label": "Avg Rating", "value": "4.9 ★"},
      ].map((s) => StatData(label: s["label"]!, value: s["value"]!)).toList(),
    );

    return data;
  }
}

// --- 3. Main Widget ---

class LogisticsDashboardPage extends StatefulWidget {
  const LogisticsDashboardPage({super.key});

  @override
  State<LogisticsDashboardPage> createState() => _LogisticsDashboardPageState();
}

class _LogisticsDashboardPageState extends State<LogisticsDashboardPage> {
  // Initial loading state is true
  bool _isLoading = true;
  LogisticsDashboardData? _dashboardData;

  final LogisticsService _service = LogisticsService();

  final Color primaryColor = const Color(0xFFEF4444); // Red-500
  final Color backgroundColor = const Color(0xFFF8FAFC); // Slate-50

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchDashboardData();
      setState(() {
        _dashboardData = data;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Use a placeholder network image URL
    const String profileImageUrl = 'https://i.pravatar.cc/150?img=60';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Operations Dashboard',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () {},
            icon: const Icon(Icons.notifications_active_rounded),
            color: primaryColor,
          ),
          IconButton(
            onPressed: _isLoading ? null : () {},
            icon: const Icon(Icons.help_outline_rounded),
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black12,
            // Replaced AssetImage with NetworkImage placeholder
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildKpiRow(size),
                const SizedBox(height: 16),
                _buildMapCard(size),
                const SizedBox(height: 16),
                _buildRecentActivity(),
                const SizedBox(height: 16),
                _buildQuickStats(size),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () {},
        backgroundColor: primaryColor,
        label: const Text("Create Dispatch"),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHeader() {
    // 3. Overflow Fix: Use Flexible/Expanded for the dynamic part of the Row
    // The username is now dynamically loaded.
    final userName = _dashboardData?.userName ?? 'User';

    return Row(
      children: [
        Text(
          "Good Evening,",
          style: GoogleFonts.inter(fontSize: 18, color: Colors.grey[700]),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            // Use fetched data
            "$userName 👋",
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            // Added overflow handling for safety
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow(Size size) {
    final List<KpiData> kpiList = _dashboardData?.kpis ?? [];

    if (_isLoading || kpiList.isEmpty) {
      return _buildKpiShimmer(size);
    }

    // GridView setup is correct for responsiveness and preventing overflow
    return GridView.builder(
      shrinkWrap: true,
      itemCount: kpiList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 700 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final kpi = kpiList[index];
        return Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(kpi.icon, color: primaryColor, size: 22),
                    ),
                    const Spacer(),
                    Text(
                      kpi.delta,
                      style: GoogleFonts.inter(
                        color: kpi.delta.startsWith('+')
                            ? Colors.green
                            : Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                Text(
                  kpi.title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  kpi.value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapCard(Size size) {
    // Placeholder image URL for map
    const String mapPlaceholderUrl =
        'https://placehold.co/600x200/4F46E5/FFFFFF?text=Live+Map+Tracking';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Live Fleet Map",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isLoading ? null : () {},
                  icon: const Icon(Icons.location_on_rounded),
                  label: const Text("Center on Hub"),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
                : Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  mapPlaceholderUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: CircularProgressIndicator(
                            color: primaryColor));
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text("Map Unavailable",
                        style: GoogleFonts.inter(color: Colors.grey)),
                  ),
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              // Display status text over the map placeholder
              // child: Text(
              //   "Live location tracking enabled...",
              //   style: GoogleFonts.inter(
              //       fontSize: 13,
              //       color: Colors.white, // Changed color for contrast
              //       fontWeight: FontWeight.w500),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final List<ActivityData> activities = _dashboardData?.recentActivities ?? [];

    if (_isLoading || activities.isEmpty) {
      return _buildActivityShimmer();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Recent Activity",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text("View All",
                      style: GoogleFonts.inter(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Use fetched data
            ...activities.map(
                  (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                ),
                title: Text(item.title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(item.subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey[600])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Size size) {
    final stats = _dashboardData?.quickStats ?? [];

    if (_isLoading || stats.isEmpty) {
      return _buildQuickStatsShimmer(size);
    }

    // GridView setup is correct for responsiveness and preventing overflow
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: stats.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size.width > 700 ? 4 : 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 1,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final s = stats[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.label,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(s.value,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Shimmer Loading Widgets ---

  Widget _buildKpiShimmer(Size size) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 700 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 3,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const SizedBox(height: 100),
          ),
        );
      },
    );
  }

  Widget _buildActivityShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              3,
                  (index) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(radius: 22, backgroundColor: Colors.white),
                title: Container(
                    height: 15, width: 150, color: Colors.white, margin: const EdgeInsets.only(bottom: 4)),
                subtitle: Container(height: 12, width: 100, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsShimmer(Size size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size.width > 700 ? 4 : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              );
            },
          ),
        ),
      ),
    );
  }
}

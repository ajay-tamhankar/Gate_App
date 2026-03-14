import '../domain/dashboard_repository.dart';
import '../domain/entities/dashboard_metrics.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardMetrics> getMetrics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return const DashboardMetrics(
      totalGateEntriesToday: 24,
      totalGateEntriesMonth: 345,
      totalGrnPosted: 310,
      pendingGrnCount: 35,
      quantityMismatchCases: 8,
      duplicateGrnCases: 2,
      pendingGrnAging0To1: 20,
      pendingGrnAging2To3: 10,
      pendingGrnAgingMoreThan3: 5,
      gateTat: 45.0, // minutes
      dockTat: 120.0, // minutes
      pendingReconciliations: 23,
      matchedDraws: 110,
      exceptionsRaised: 9,
      recentActivity: [
        DailyActivity(day: 'Mon', entriesCount: 15),
        DailyActivity(day: 'Tue', entriesCount: 22),
        DailyActivity(day: 'Wed', entriesCount: 18),
        DailyActivity(day: 'Thu', entriesCount: 30),
        DailyActivity(day: 'Fri', entriesCount: 25),
        DailyActivity(day: 'Sat', entriesCount: 32),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import 'controllers/gate_entry_list_controller.dart';
import 'gate_entry_form_page.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/responsive.dart';
import '../domain/entities/gate_entry.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';

class GateEntryPage extends ConsumerWidget {
  const GateEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gateEntryListControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canCreate = role == UserRole.gateSecurity || role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(gateEntryListControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GateEntryFormPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: state.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No entries found'));
          }
          final isMob = isMobile(context);

          return RefreshIndicator(
            onRefresh: () async =>
                ref.read(gateEntryListControllerProvider.notifier).refresh(),
            child: isMob
                ? _buildMobileList(entries)
                : _buildDesktopTable(entries, context),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMobileList(List<GateEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isGateIn = entry.gateDirection == 'Gate In';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isGateIn
                  ? Colors.indigo.shade100
                  : Colors.deepOrange.shade100,
              child: Icon(
                isGateIn ? Icons.login : Icons.logout,
                color: isGateIn ? Colors.indigo : Colors.deepOrange,
              ),
            ),
            title: Text('${entry.challanNumber} (${entry.materialCode})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Vendor: ${entry.vendorName} | Qty: ${entry.quantity}'),
                Text('Transporter: ${entry.transporterName}'),
                const SizedBox(height: 4),
                Text(
                  'Entry: ${DateFormat('MMM dd, HH:mm').format(entry.entryTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(entry.status),
              backgroundColor: entry.status == 'Pending'
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
            ),
            isThreeLine: true,
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<GateEntry> entries, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 16,
          minWidth: 1000,
          columns: const [
            DataColumn2(label: Text('Direction'), size: ColumnSize.S),
            DataColumn2(label: Text('Challan No'), size: ColumnSize.M),
            DataColumn2(label: Text('Material'), size: ColumnSize.S),
            DataColumn2(label: Text('Qty'), size: ColumnSize.S, numeric: true),
            DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
            DataColumn2(label: Text('Transporter'), size: ColumnSize.L),
            DataColumn2(label: Text('Entry Time'), size: ColumnSize.M),
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
          ],
          rows: entries.map((entry) {
            final isGateIn = entry.gateDirection == 'Gate In';
            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    Icon(isGateIn ? Icons.login : Icons.logout,
                        size: 16,
                        color: isGateIn ? Colors.indigo : Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(entry.gateDirection),
                  ],
                )),
                DataCell(Text(entry.challanNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(entry.materialCode)),
                DataCell(Text(entry.quantity.toString())),
                DataCell(Text(entry.vendorName)),
                DataCell(Text(entry.transporterName)),
                DataCell(
                    Text(DateFormat('MMM dd, HH:mm').format(entry.entryTime))),
                DataCell(
                  Chip(
                    label: Text(entry.status,
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: entry.status == 'Pending'
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

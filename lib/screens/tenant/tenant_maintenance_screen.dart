import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/maintenance_model.dart';
import '../../../models/user_model.dart';
import '../../../services/maintenance_service.dart';

class TenantMaintenanceScreen extends StatefulWidget {
  final UserModel user;
  // const TenantMaintenanceScreen({super.key, required this.user});
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const TenantMaintenanceScreen({super.key, required this.user, this.scaffoldKey});

  @override
  State<TenantMaintenanceScreen> createState() => _TenantMaintenanceScreenState();
}

class _TenantMaintenanceScreenState extends State<TenantMaintenanceScreen> {
  Map<String, dynamic>? _tenantData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTenant();
  }

  Future<void> _loadTenant() async {
    final snap = await FirebaseFirestore.instance
        .collection('tenants')
        .where('email', isEqualTo: widget.user.email)
        .where('isActive', isEqualTo: true)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        _tenantData = {...snap.docs.first.data(), 'id': snap.docs.first.id};
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _showAddRequestDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('মেরামতের অনুরোধ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'সমস্যার শিরোনাম',
                  hintText: 'যেমন: পানির লাইন লিক করছে',
                ),
                validator: (v) => v!.isEmpty ? 'শিরোনাম দিন' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'বিস্তারিত বিবরণ',
                  hintText: 'সমস্যাটি বিস্তারিত লিখুন',
                ),
                validator: (v) => v!.isEmpty ? 'বিবরণ দিন' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 50,
                child: FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final req = MaintenanceModel(
                      id: '',
                      tenantId: _tenantData!['id'],
                      tenantName: _tenantData!['name'],
                      roomNumber: _tenantData!['roomNumber'],
                      propertyId: _tenantData!['propertyId'],
                      propertyName: _tenantData!['propertyName'],
                      landlordId: _tenantData!['landlordId'],
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      status: MaintenanceStatus.pending,
                      createdAt: DateTime.now(),
                    );
                    await MaintenanceService().addRequest(req);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('অনুরোধ পাঠান'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('মেরামতের অনুরোধ'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tenantData == null
              ? const Center(child: Text('তথ্য পাওয়া যায়নি'))
              : StreamBuilder<List<MaintenanceModel>>(
                  stream: MaintenanceService().getTenantRequests(_tenantData!['id']),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final requests = snap.data ?? [];
                    if (requests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.build_outlined, size: 80,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text('কোনো অনুরোধ নেই',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('নিচের বাটন দিয়ে অনুরোধ পাঠান'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (ctx, i) {
                        final req = requests[i];
                        final color = Theme.of(context).colorScheme;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(req.title,
                                          style: const TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(int.parse('FF${req.statusColorHex}', radix: 16)).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(req.statusLabel,
                                          style: TextStyle(fontSize: 12, color: Color(int.parse('FF${req.statusColorHex}', radix: 16)),
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(req.description,
                                    style: TextStyle(
                                        color: color.onSurface.withOpacity(0.7))),
                                const SizedBox(height: 6),
                                Text(
                                  '${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color.onSurface.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: _tenantData == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddRequestDialog,
              icon: const Icon(Icons.add),
              label: const Text('অনুরোধ পাঠান'),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype/admin_app/core/push_notification/send_push_notification.dart';
import 'package:prototype/utils/colors.dart';

class StocksPage extends StatefulWidget {
  StocksPage({super.key});

  @override
  State<StocksPage> createState() => _SingleStockAdminPageState();
}

class _SingleStockAdminPageState extends State<StocksPage> {
  final TextEditingController stockNameController = TextEditingController();
  final TextEditingController slController = TextEditingController();
  final TextEditingController tgt1Controller = TextEditingController();
  final TextEditingController tgt2Controller = TextEditingController();
  final TextEditingController tgt3Controller = TextEditingController();

  String? selectedAction;
  bool isLoading = false;
  String? stockDocId;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    stockNameController.dispose();
    slController.dispose();
    tgt1Controller.dispose();
    tgt2Controller.dispose();
    tgt3Controller.dispose();
    super.dispose();
  }

  /// Update Firestore field live
  Future<void> updateLiveField(String field, dynamic value) async {
    if (stockDocId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('stocks')
          .doc(stockDocId)
          .update({
            field: value,
            "statusUpdatedAt": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating $field: $e")));
    }
  }

  /// Notify active users
  Future<void> notifyActiveUsers({
    String? action,
    String? stockName,
    String? sl,
    String? tgt1,
    String? tgt2,
    String? tgt3,
    bool isTargetUpdate = false,
  }) async {
    await sendPushNotificationToActiveUsers(
      projectId: "ozvol-admin",
      action: action,
      stockName: stockName ?? "",
      isTargetUpdate: isTargetUpdate,
      extraData: {
        if (sl != null && sl.isNotEmpty) "SL": sl,
        if (tgt1 != null && tgt1.isNotEmpty) "TGT1": tgt1,
        if (tgt2 != null && tgt2.isNotEmpty) "TGT2": tgt2,
        if (tgt3 != null && tgt3.isNotEmpty) "TGT3": tgt3,
      },
    );
  }

  /// Save / Update SL & Targets
  Future<void> saveStock() async {
    if (stockDocId == null) return;

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('stocks')
          .doc(stockDocId)
          .update({
            "sl": slController.text,
            "tgt1": tgt1Controller.text,
            "tgt2": tgt2Controller.text,
            "tgt3": tgt3Controller.text,
            "targetsUpdatedAt": FieldValue.serverTimestamp(),
          });

      // ✅ Notify with isTargetUpdate true
      await notifyActiveUsers(
        stockName: stockNameController.text,
        sl: slController.text,
        tgt1: tgt1Controller.text,
        tgt2: tgt2Controller.text,
        tgt3: tgt3Controller.text,
        isTargetUpdate: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stock fields updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating stock: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget actionButton(String action, Color color) {
    final isSelected = selectedAction?.toLowerCase() == action.toLowerCase();
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          setState(() => selectedAction = action);
          await updateLiveField("action", action);

          // ✅ Notify only action updates
          await notifyActiveUsers(
            stockName: stockNameController.text,
            action: action,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: isSelected ? Colors.white : color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(action),
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    bool liveUpdate = false,
    String? fieldName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          style: const TextStyle(color: Colors.white),
          controller: controller,
          onChanged: liveUpdate && fieldName != null
              ? (value) async {
                  await updateLiveField(fieldName, value);

                  // ✅ Prevent sending empty action
                  if (selectedAction != null && selectedAction!.isNotEmpty) {
                    await notifyActiveUsers(
                      stockName: stockNameController.text,
                      action: selectedAction,
                    );
                  }
                }
              : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kprimerycolor,
      appBar: AppBar(
        title: const Text("Single Stock Admin"),
        backgroundColor: kprimerycolor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stocks')
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No stock found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final stock = snapshot.data!.docs.first;
          stockDocId = stock.id;
          final data = stock.data() as Map<String, dynamic>;

          if (!_controllersInitialized) {
            stockNameController.text = data['stockName'] ?? '';
            slController.text = data['sl'] ?? '';
            tgt1Controller.text = data['tgt1'] ?? '';
            tgt2Controller.text = data['tgt2'] ?? '';
            tgt3Controller.text = data['tgt3'] ?? '';
            selectedAction = data['action'];
            _controllersInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputField(
                  "Stock Name",
                  stockNameController,
                  liveUpdate: true,
                  fieldName: "stockName",
                ),
                const Text(
                  "Buy Or Sell",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    actionButton("Buy", Colors.blue),
                    const SizedBox(width: 10),
                    actionButton("Sell", Colors.green),
                    const SizedBox(width: 10),
                    actionButton("Exit", Colors.red),
                  ],
                ),
                const SizedBox(height: 20),
                inputField("SL", slController),
                inputField("TGT 1", tgt1Controller),
                inputField("TGT 2", tgt2Controller),
                inputField("TGT 3", tgt3Controller),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveStock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kseccolor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Save / Update"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

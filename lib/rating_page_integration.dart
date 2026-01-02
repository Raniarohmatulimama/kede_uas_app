import 'package:flutter/material.dart';
import 'rating_service.dart';

class RatingPageIntegration extends StatefulWidget {
  final String orderId;
  final List items; // product list from order
  const RatingPageIntegration({
    super.key,
    required this.orderId,
    required this.items,
  });

  @override
  State<RatingPageIntegration> createState() => _RatingPageIntegrationState();
}

class _RatingPageIntegrationState extends State<RatingPageIntegration> {
  final service = RatingService();
  final Map<String, int> ratings = {};
  final Map<String, String> comments = {};
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final can = await service.canSubmit(widget.orderId);
      if (!can) throw Exception('Order not completed');
      for (final item in widget.items) {
        final m = item as Map<String, dynamic>;
        final pid = m['productId'] ?? m['id'];
        final r = ratings[pid];
        if (r == null) continue;
        await service.submitRating(
          orderId: widget.orderId,
          productId: pid,
          rating: r,
          comment: comments[pid],
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ratings submitted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating')),
      body: ListView(
        children: [
          for (final item in widget.items)
            ListTile(
              title: Text(item['name'] ?? '-'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<int>(
                    value: ratings[item['productId'] ?? item['id']],
                    hint: const Text('Select rating'),
                    items: List.generate(5, (i) => i + 1)
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      final pid = item['productId'] ?? item['id'];
                      ratings[pid] = v ?? 1;
                    }),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                    ),
                    onChanged: (v) {
                      final pid = item['productId'] ?? item['id'];
                      comments[pid] = v;
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Rating'),
        ),
      ),
    );
  }
}

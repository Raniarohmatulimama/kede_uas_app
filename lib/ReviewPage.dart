import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home/HomePage.dart';
import 'rating_service.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const ReviewPage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 3; // Default rating 3.0
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;
  final _ratingService = RatingService();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // Get ALL products from order
    final items = (widget.orderDetails['items'] as List<dynamic>?) ?? [];

    print('DEBUG ReviewPage: orderDetails keys = ${widget.orderDetails.keys}');
    print('DEBUG ReviewPage: orderDetails = ${widget.orderDetails}');
    print('DEBUG ReviewPage: items = $items');

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk untuk diberi rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Try multiple possible keys for orderId
    final orderId =
        widget.orderDetails['orderId'] ??
        widget.orderDetails['id'] ??
        widget.orderDetails['documentId'] ??
        widget.orderDetails['_id'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    print(
      'DEBUG ReviewPage: Submitting review for ${items.length} products - orderId: $orderId, rating: $_rating',
    );

    setState(() => _isSubmitting = true);

    try {
      // Submit rating & review untuk SEMUA produk dalam order
      int successCount = 0;
      for (final item in items) {
        final product = item as Map<String, dynamic>;
        final productId = product['productId'] ?? product['id'];

        print('DEBUG ReviewPage: Processing item = $product');
        print('DEBUG ReviewPage: productId = $productId');

        if (productId == null) {
          print('DEBUG ReviewPage: SKIP - productId is null');
          continue;
        }

        try {
          await _ratingService.submitRating(
            orderId: orderId,
            productId: productId,
            rating: _rating,
            comment: _reviewController.text.isEmpty
                ? null
                : _reviewController.text,
          );
          successCount++;
          print(
            'DEBUG ReviewPage: Successfully submitted rating for productId: $productId',
          );
        } catch (itemError) {
          print(
            'DEBUG ReviewPage: Error submitting rating for productId $productId: $itemError',
          );
          // Continue dengan produk berikutnya jika ada error
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount produk berhasil diberi rating!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home after successful submission
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('ERROR ReviewPage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Rate this product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Rating Number
                  Text(
                    '$_rating.0',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFF8C42),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),

                  // Review Text Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Let us know what you think',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'Write your review here',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CB32B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'SUBMIT REVIEW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

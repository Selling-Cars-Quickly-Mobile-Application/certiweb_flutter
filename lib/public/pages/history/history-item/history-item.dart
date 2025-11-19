import 'package:flutter/material.dart';

class HistoryItemWidget extends StatelessWidget {
  final Map<String, dynamic> reservation;
  const HistoryItemWidget({super.key, required this.reservation});

  String _formatDateTime(String? s) {
    if (s == null || s.isEmpty) return 'Fecha no especificada';
    try {
      final d = DateTime.tryParse(s);
      if (d == null) return 'Fecha inválida';
      return d.toLocal().toString().split('.')[0];
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'accepted':
      case 'confirmada':
        return const Color(0xFF28a745);
      case 'pending':
      case 'pendiente':
        return const Color(0xFFffc107);
      case 'cancelled':
      case 'cancelada':
        return const Color(0xFFdc3545);
      case 'completed':
      case 'completada':
        return const Color(0xFF007bff);
      default:
        return const Color(0xFF6c757d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (reservation['imageUrl'] ?? '').toString();
    final name = (reservation['reservationName'] ?? 'N/A').toString();
    final brand = (reservation['brand'] ?? '').toString();
    final model = (reservation['model'] ?? '').toString();
    final date = _formatDateTime((reservation['inspectionDateTime'] ?? '').toString());
    final price = (reservation['price'] ?? '').toString();
    final status = (reservation['status'] ?? '').toString();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl.isEmpty
                    ? 'https://static.vecteezy.com/system/resources/previews/005/720/408/non_2x/crossed-image-icon-picture-not-available-delete-picture-symbol-free-vector.jpg'
                    : imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Image.network(
                  'https://static.vecteezy.com/system/resources/previews/005/720/408/non_2x/crossed-image-icon-picture-not-available-delete-picture-symbol-free-vector.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D2B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1E4D2B),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$brand - $model',
                    style: const TextStyle(
                      color: Color(0xFF1E4D2B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Fecha y hora', date),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Divider(
                          height: 12,
                          thickness: 1,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                      _buildDetailRow('Precio', 'S/ $price'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Divider(
                          height: 12,
                          thickness: 1,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estado',
                            style: TextStyle(
                              color: Color(0xFF2c3e50),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2c3e50),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF495057),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
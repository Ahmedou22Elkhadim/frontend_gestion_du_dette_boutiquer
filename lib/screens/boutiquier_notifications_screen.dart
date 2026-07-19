// screens/boutiquier_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class BoutiquierNotificationsScreen extends StatefulWidget {
  const BoutiquierNotificationsScreen({super.key});

  @override
  State<BoutiquierNotificationsScreen> createState() =>
      _BoutiquierNotificationsScreenState();
}

class _BoutiquierNotificationsScreenState
    extends State<BoutiquierNotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notifications = await authProvider.getNotifications();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _markAsRead(dynamic notification) async {
    if (notification['est_lue'] == true) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.marquerNotificationLue(notification['id']);

    if (success && mounted) {
      setState(() {
        notification['est_lue'] = true;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.marquerToutesNotificationsLues();

    if (success && mounted) {
      setState(() {
        for (final notification in _notifications) {
          notification['est_lue'] = true;
        }
      });
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'ajout_dette':
        return Icons.add_circle_outline;
      case 'modification_dette':
        return Icons.edit_outlined;
      case 'suppression_dette':
        return Icons.delete_outline;
      case 'paiement':
        return Icons.check_circle_outline;
      case 'demande_ajout':
        return Icons.person_add;
      case 'demande_suppression':
        return Icons.person_remove;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorFor(String? type) {
    switch (type) {
      case 'ajout_dette':
        return Colors.blue;
      case 'modification_dette':
        return Colors.orange;
      case 'suppression_dette':
        return Colors.red;
      case 'paiement':
        return Colors.green;
      case 'demande_ajout':
      case 'demande_suppression':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';
    final hasUnread = _notifications.any((n) => n['est_lue'] != true);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            if (hasUnread)
              TextButton(
                onPressed: _markAllAsRead,
                child: const Text(
                  'Tout marquer lu',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadNotifications,
          color: Colors.green,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text('Impossible de charger les notifications'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Aucune notification pour le moment',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final bool estLue = notification['est_lue'] == true;
        final color = _colorFor(notification['type_notification']);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: estLue ? 0 : 2,
          color: estLue ? Colors.white : const Color(0xFFF5FBF6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: estLue
                ? BorderSide(color: Colors.grey.shade200)
                : BorderSide(color: Colors.green.shade200, width: 1.5),
          ),
          child: ListTile(
            onTap: () => _markAsRead(notification),
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: color.withAlpha(40),
              child: Icon(_iconFor(notification['type_notification']), color: color),
            ),
            title: Text(
              notification['titre'] ?? '',
              style: TextStyle(
                fontWeight: estLue ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification['message'] ?? ''),
                const SizedBox(height: 6),
                Text(
                  _formatDate(notification['date_creation']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: estLue
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

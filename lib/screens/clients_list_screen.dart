// screens/clients_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/shop_provider.dart';
import 'client_dette_detail_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  List<dynamic> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clients = await authProvider.getClients();
    setState(() {
      _clients = clients;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clients = await authProvider.getClients();
    setState(() {
      _clients = clients;
    });
  }

  Future<void> _supprimerClient(dynamic client) async {
    // Demander confirmation avant d'envoyer la demande de suppression
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer client'),
        content: Text(
          'Voulez-vous demander la suppression de ${client['user_nom']} ?\n\n'
          'Une demande sera envoyée au client qui devra l\'accepter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Demander suppression'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.envoyerDemandeSuppression(client['user']);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande de suppression envoyée au client'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        await _refreshData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur lors de l\'envoi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _voirDetails(dynamic client) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetteDetailScreen(
          clientId: client['user'],
          clientName: client['user_nom'] ?? 'Client',
          clientPhone: client['user_phone'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.getText('client_list')),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.green,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _clients.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucun client'),
                          Text(
                            'Ajoutez des clients pour commencer',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clients.length,
                      itemBuilder: (context, index) {
                        final client = _clients[index];
                        return Dismissible(
                          key: Key(client['id'].toString()),
                          direction: DismissDirection.endToStart, // Seulement vers la gauche
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.white, size: 30),
                                SizedBox(height: 4),
                                Text(
                                  'Glisser pour supprimer',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // 🔥 CORRECTION: Utiliser confirmDismiss au lieu de onDismissed
                          confirmDismiss: (direction) async {
                            // Afficher le dialogue de confirmation
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer client'),
                                content: Text(
                                  'Voulez-vous demander la suppression de ${client['user_nom']} ?\n\n'
                                  'Une demande sera envoyée au client qui devra l\'accepter.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Demander suppression'),
                                  ),
                                ],
                              ),
                            );
                            
                            // Si l'utilisateur confirme, envoyer la demande
                            if (confirm == true) {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final success = await authProvider.envoyerDemandeSuppression(client['user']);
                              
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Demande de suppression envoyée au client'),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                await _refreshData();
                                return true; // Confirme la suppression visuelle
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage ?? 'Erreur lors de l\'envoi'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return false; // Annule la suppression visuelle
                              }
                            }
                            
                            return false; // Annule la suppression visuelle
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  (client['user_nom'] ?? 'C')[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                client['user_nom'] ?? 'Client',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(client['user_phone'] ?? '---'),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 16,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.credit_score, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Total: ${(client['total_dettes'] as num?)?.toDouble() ?? 0} FCFA',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pending, size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Impayées: ${client['dettes_impayees'] ?? 0}',
                                            style: const TextStyle(fontSize: 12, color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () => _voirDetails(client),
                              ),
                              onTap: () => _voirDetails(client),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
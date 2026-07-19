// screens/client_demandes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';

class ClientDemandesScreen extends StatefulWidget {
  const ClientDemandesScreen({super.key});

  @override
  State<ClientDemandesScreen> createState() => _ClientDemandesScreenState();
}

class _ClientDemandesScreenState extends State<ClientDemandesScreen> {
  List<dynamic> _demandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final demandes = await authProvider.getClientDemandes();
    setState(() {
      _demandes = demandes;
      _isLoading = false;
    });
  }

  Future<void> _repondreDemande(int demandeId, bool accepter, dynamic demande) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    final success = await authProvider.repondreDemande(demandeId, accepter);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accepter ? 'Demande acceptée' : 'Demande refusée'),
          backgroundColor: accepter ? Colors.green : Colors.red,
        ),
      );
      
      // Rafraîchir la liste des demandes
      await _loadDemandes();
      
      // Si la demande est acceptée, rafraîchir les boutiques
      if (accepter) {
        await shopProvider.fetchShops(authProvider);
        await shopProvider.fetchTotalDette(authProvider);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du traitement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDemandes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDemandes,
        color: Colors.green,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _demandes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucune demande en attente'),
                        SizedBox(height: 8),
                        Text(
                          'Les boutiquiers vous enverront des demandes ici',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _demandes.length,
                    itemBuilder: (context, index) {
                      final demande = _demandes[index];
                      final bool estEnAttente = demande['statut'] == 'en_attente';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: estEnAttente
                                ? Border.all(color: Colors.orange, width: 1)
                                : null,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: demande['type_demande'] == 'ajout'
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    demande['type_demande'] == 'ajout'
                                        ? Icons.person_add
                                        : Icons.person_remove,
                                    color: demande['type_demande'] == 'ajout'
                                        ? Colors.green
                                        : Colors.red,
                                    size: 30,
                                  ),
                                ),
                                title: Text(
                                  demande['boutiquier_nom'] ?? 'Boutiquier',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      demande['type_demande'] == 'ajout'
                                          ? 'Demande d\'ajout'
                                          : 'Demande de suppression',
                                      style: TextStyle(
                                        color: demande['type_demande'] == 'ajout'
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (demande['adresse'] != null && demande['adresse'].isNotEmpty)
                                      Text(
                                        'Adresse: ${demande['adresse']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    if (demande['message'] != null && demande['message'].isNotEmpty)
                                      Text(
                                        'Message: ${demande['message']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    const SizedBox(height: 8),
                                    if (!estEnAttente)
                                      Chip(
                                        label: Text(
                                          demande['statut'] == 'acceptee' ? 'Acceptée' : 'Refusée',
                                          style: TextStyle(
                                            color: demande['statut'] == 'acceptee'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        backgroundColor: demande['statut'] == 'acceptee'
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                      ),
                                  ],
                                ),
                              ),
                              if (estEnAttente)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _repondreDemande(
                                            demande['id'], 
                                            true, 
                                            demande
                                          ),
                                          icon: const Icon(Icons.check, size: 18),
                                          label: const Text('Accepter'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _repondreDemande(
                                            demande['id'], 
                                            false, 
                                            demande
                                          ),
                                          icon: const Icon(Icons.close, size: 18),
                                          label: const Text('Refuser'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      
    );
  }
}
// screens/client_dette_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class ClientDetteDetailScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final String clientPhone;
  
  const ClientDetteDetailScreen({
    super.key,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
  });

  @override
  State<ClientDetteDetailScreen> createState() => _ClientDetteDetailScreenState();
}

class _ClientDetteDetailScreenState extends State<ClientDetteDetailScreen> {
  List<dynamic> _dettes = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDettes();
  }

  Future<void> _loadDettes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dettes = await authProvider.getDettes(clientId: widget.clientId);
    
    setState(() {
      _dettes = dettes;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadDettes();
  }

  Future<void> _ajouterDette() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddDetteDialog(clientId: widget.clientId),
    );
    
    if (result == true) {
      await _loadDettes();
    }
  }

  Future<void> _modifierDette(dynamic dette) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditDetteDialog(dette: dette),
    );
    
    if (result == true) {
      await _loadDettes();
    }
  }

  Future<void> _supprimerDette(int detteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dette'),
        content: const Text('Voulez-vous vraiment supprimer cette dette ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteDette(detteId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dette supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadDettes();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _marquerPayee(int detteId, bool estPayee) async {
    if (estPayee) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.marquerDettePayee(detteId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dette marquée comme payée'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadDettes();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du paiement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';
    
    double totalDettes = 0;
    for (var dette in _dettes) {
      totalDettes += (dette['montant'] as num?)?.toDouble() ?? 0;
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.clientName),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _ajouterDette,
              tooltip: 'Ajouter une dette',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.green,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Carte de résumé
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total des dettes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${totalDettes.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nombre de dettes',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_dettes.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Téléphone',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.clientPhone,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste des dettes
                    Expanded(
                      child: _dettes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune dette pour ce client',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _ajouterDette,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Ajouter une dette'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _dettes.length,
                              itemBuilder: (context, index) {
                                final dette = _dettes[index];
                                return _buildDetteCard(dette);
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetteCard(dynamic dette) {
    final bool estPayee = dette['est_payee'] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(dette['id'].toString()),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) => _supprimerDette(dette['id']),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: estPayee ? Colors.green : Colors.orange,
            child: Icon(
              estPayee ? Icons.check : Icons.pending,
              color: Colors.white,
            ),
          ),
          title: Text(
            dette['produit']?.isNotEmpty == true
                ? dette['produit']
                : dette['description'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${dette['description']}'),
              if (dette['quantite'] > 1)
                Text('Quantité: ${dette['quantite']}'),
              if (dette['date_echeance'] != null)
                Text(
                  'Échéance: ${dette['date_echeance']}',
                  style: const TextStyle(fontSize: 12),
                ),
              Text(
                'Date: ${dette['date_creation']?.substring(0, 10) ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(dette['montant'] as num?)?.toDouble() ?? 0} FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: estPayee ? Colors.green : Colors.red,
                ),
              ),
              if (!estPayee)
                const SizedBox(height: 8),
              if (!estPayee)
                ElevatedButton(
                  onPressed: () => _marquerPayee(dette['id'], estPayee),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(80, 30),
                  ),
                  child: const Text('Payer', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          onTap: () => _modifierDette(dette),
        ),
      ),
    );
  }
}

// Dialog pour ajouter une dette
class AddDetteDialog extends StatefulWidget {
  final int clientId;
  
  const AddDetteDialog({super.key, required this.clientId});

  @override
  State<AddDetteDialog> createState() => _AddDetteDialogState();
}

class _AddDetteDialogState extends State<AddDetteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _produitController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _dateEcheanceController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    _produitController.dispose();
    _quantiteController.dispose();
    _dateEcheanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.createDette(
      clientId: widget.clientId,
      description: _descriptionController.text,
      montant: double.parse(_montantController.text),
      produit: _produitController.text,
      quantite: int.tryParse(_quantiteController.text) ?? 1,
      dateEcheance: _dateEcheanceController.text.isNotEmpty 
          ? _dateEcheanceController.text 
          : null,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success != null && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une dette'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _produitController,
                decoration: const InputDecoration(
                  labelText: 'Produit (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant *',
                  border: OutlineInputBorder(),
                  prefixText: 'FCFA ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le montant est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateEcheanceController,
                decoration: const InputDecoration(
                  labelText: 'Date d\'échéance (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}

// Dialog pour modifier une dette
class EditDetteDialog extends StatefulWidget {
  final dynamic dette;
  
  const EditDetteDialog({super.key, required this.dette});

  @override
  State<EditDetteDialog> createState() => _EditDetteDialogState();
}

class _EditDetteDialogState extends State<EditDetteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _produitController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _dateEcheanceController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.dette['description'] ?? '';
    _montantController.text = (widget.dette['montant'] as num?)?.toString() ?? '';
    _produitController.text = widget.dette['produit'] ?? '';
    _quantiteController.text = (widget.dette['quantite'] ?? 1).toString();
    _dateEcheanceController.text = widget.dette['date_echeance'] ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    _produitController.dispose();
    _quantiteController.dispose();
    _dateEcheanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateDette(
      widget.dette['id'],
      {
        'description': _descriptionController.text,
        'montant': double.parse(_montantController.text),
        'produit': _produitController.text,
        'quantite': int.tryParse(_quantiteController.text) ?? 1,
        'date_echeance': _dateEcheanceController.text.isNotEmpty 
            ? _dateEcheanceController.text 
            : null,
      },
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la modification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la dette'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _produitController,
                decoration: const InputDecoration(
                  labelText: 'Produit (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant *',
                  border: OutlineInputBorder(),
                  prefixText: 'FCFA ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le montant est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateEcheanceController,
                decoration: const InputDecoration(
                  labelText: 'Date d\'échéance (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Modifier'),
        ),
      ],
    );
  }
}
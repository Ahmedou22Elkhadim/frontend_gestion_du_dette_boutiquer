// screens/boutiquier_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class ShopDetailScreen extends StatefulWidget {
  final int boutiqueId;
  final String boutiqueNom;
  final String boutiquePhone;
  final String? boutiqueAdresse;

  const ShopDetailScreen({
    super.key,
    required this.boutiqueId,
    required this.boutiqueNom,
    required this.boutiquePhone,
    this.boutiqueAdresse,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  List<dynamic> _dettes = [];
  bool _isLoading = true;
  double _totalDettes = 0;
  int _dettesPayees = 0;
  int _dettesImpayees = 0;

  @override
  void initState() {
    super.initState();
    _loadDettes();
  }

  Future<void> _loadDettes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = await authProvider.getClientDettes();
    
    setState(() {
      _isLoading = false;
      
      if (data != null && data['dettes_par_boutique'] != null) {
        // Trouver les dettes de cette boutique
        final boutiqueData = data['dettes_par_boutique'].firstWhere(
          (b) => b['boutique_id'] == widget.boutiqueId,
          orElse: () => null,
        );
        
        if (boutiqueData != null) {
          _dettes = boutiqueData['dettes'] ?? [];
          
          // Calculer les statistiques
          for (var dette in _dettes) {
            _totalDettes += (dette['montant'] as num?)?.toDouble() ?? 0;
            if (dette['est_payee'] == true) {
              _dettesPayees++;
            } else {
              _dettesImpayees++;
            }
          }
        }
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _totalDettes = 0;
      _dettesPayees = 0;
      _dettesImpayees = 0;
    });
    await _loadDettes();
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.boutiqueNom),
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
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Informations de la boutique
                      _buildShopInfoCard(),
                      const SizedBox(height: 16),
                      
                      // Statistiques des dettes
                      _buildStatsCard(),
                      const SizedBox(height: 16),
                      
                      // Liste des dettes
                      _buildDettesList(language),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    widget.boutiqueNom.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.boutiqueNom,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          widget.boutiquePhone,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    if (widget.boutiqueAdresse != null && widget.boutiqueAdresse!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.boutiqueAdresse!,
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.credit_score, size: 30, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  '${_totalDettes.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text('Total dû', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 30, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  '$_dettesPayees',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Text('Payées', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.pending, size: 30, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  '$_dettesImpayees',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Text('Impayées', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDettesList(LanguageProvider language) {
    if (_dettes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune dette pour cette boutique',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Liste des dettes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _dettes.length,
          itemBuilder: (context, index) {
            final dette = _dettes[index];
            return _buildDetteCard(dette);
          },
        ),
      ],
    );
  }

  Widget _buildDetteCard(dynamic dette) {
    final bool estPayee = dette['est_payee'] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: estPayee
              ? Border.all(color: Colors.green.shade200)
              : Border.all(color: Colors.orange.shade200),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: estPayee ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              estPayee ? Icons.check : Icons.pending,
              color: estPayee ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          title: Text(
            dette['produit']?.isNotEmpty == true
                ? dette['produit']
                : dette['description'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dette['description'] != null && dette['description'] != dette['produit'])
                Text(
                  dette['description'],
                  style: const TextStyle(fontSize: 12),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                children: [
                  if (dette['quantite'] > 1)
                    Text(
                      'Qté: ${dette['quantite']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  if (dette['date_echeance'] != null)
                    Text(
                      'Échéance: ${dette['date_echeance']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  Text(
                    'Date: ${dette['date_creation']?.substring(0, 10) ?? ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
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
              const SizedBox(height: 4),
              if (estPayee)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Payée',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
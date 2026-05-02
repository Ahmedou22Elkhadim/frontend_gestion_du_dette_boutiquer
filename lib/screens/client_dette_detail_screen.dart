// // screens/client_dette_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';

// class ClientDetteDetailScreen extends StatefulWidget {
//   final int boutiqueId;
//   final String boutiqueNom;
  
//   const ClientDetteDetailScreen({
//     super.key,
//     required this.boutiqueId,
//     required this.boutiqueNom,
//   });

//   @override
//   State<ClientDetteDetailScreen> createState() => _ClientDetteDetailScreenState();
// }

// class _ClientDetteDetailScreenState extends State<ClientDetteDetailScreen> {
//   List<dynamic> _dettes = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDettes();
//   }

//   Future<void> _loadDettes() async {
//     final apiProvider = Provider.of<ApiProvider>(context, listen: false);
//     final data = await apiProvider.getClientDettes();
    
//     setState(() {
//       if (data != null && data['dettes_par_boutique'] != null) {
//         final boutiqueData = data['dettes_par_boutique'].firstWhere(
//           (b) => b['boutique_id'] == widget.boutiqueId,
//           orElse: () => null,
//         );
//         _dettes = boutiqueData?['dettes'] ?? [];
//       }
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.boutiqueNom),
//         backgroundColor: const Color(0xFF4CAF50),
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _dettes.isEmpty
//               ? const Center(child: Text('Aucune dette'))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _dettes.length,
//                   itemBuilder: (context, index) {
//                     final dette = _dettes[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: dette['est_payee']
//                               ? Colors.green
//                               : Colors.orange,
//                           child: Icon(
//                             dette['est_payee']
//                                 ? Icons.check
//                                 : Icons.pending,
//                             color: Colors.white,
//                           ),
//                         ),
//                         title: Text(
//                           dette['produit']?.isNotEmpty == true
//                               ? dette['produit']
//                               : dette['description'],
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Quantité: ${dette['quantite']}'),
//                             if (dette['date_echeance'] != null)
//                               Text('Échéance: ${dette['date_echeance']}'),
//                           ],
//                         ),
//                         trailing: Text(
//                           '${dette['montant']} FCFA',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: dette['est_payee'] ? Colors.green : Colors.red,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
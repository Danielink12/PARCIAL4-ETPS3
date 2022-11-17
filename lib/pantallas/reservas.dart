import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Reservas extends StatefulWidget {
  const Reservas({super.key});

  @override
  State<Reservas> createState() => _ReservasState();
}

class _ReservasState extends State<Reservas> {
  // text fields' controllers
  final TextEditingController _destinoController = TextEditingController();

  final CollectionReference _reservas =
      FirebaseFirestore.instance.collection('reservas');

//actualizar poducto

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _destinoController.text = documentSnapshot['destino'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _destinoController,
                  decoration: const InputDecoration(labelText: 'Destino'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Cambiar destino'),
                  onPressed: () async {
                    final String destino = _destinoController.text;
                    if (destino != null) {
                      await _reservas
                          .doc(documentSnapshot!.id)
                          .update({"destino": destino});
                      _destinoController.text = '';
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Se cambio el destino correctamente')));
                    }
                  },
                )
              ],
            ),
          );
        });
  }

//borrar productos
  Future<void> _delete(String reservaId) async {
    await _reservas.doc(reservaId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La reserva se elimino correctamente')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Reservas realizadas')),
      ),
      body: StreamBuilder(
        stream: _reservas.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['clientes'].toString()),
                    subtitle: Text(documentSnapshot['destino'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

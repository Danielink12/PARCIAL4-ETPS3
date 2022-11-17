import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parcialdannyfer4/pantallas/reservas.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  // text fields' controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();

  final CollectionReference _vuelos =
      FirebaseFirestore.instance.collection('vuelos');

  final CollectionReference _reserva =
      FirebaseFirestore.instance.collection('reservas');
//insertar reserva
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
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
                  controller: _nombreController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del cliente'),
                ),
                TextField(
                  controller: _destinoController,
                  decoration: const InputDecoration(labelText: 'Destino'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Reservar'),
                  onPressed: () async {
                    final String nombre = _nombreController.text;
                    final String destino = _destinoController.text;
                    if (destino != null) {
                      await _reserva
                          .add({"clientes": nombre, "destino": destino});
                      _nombreController.text = '';
                      _destinoController.text = '';
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('La reserva fue realizada correctamente')));
                    }
                  },
                )
              ],
            ),
          );
        });
  }

//MOSTRAR DETALLES DE VUELOS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Parcial4 - Reserva de vuelos'),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Reservas()));
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: _vuelos.snapshots(),
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
                      title: Text('Destino: ' +
                          documentSnapshot['destino'].toString() +
                          '-' +
                          documentSnapshot['marca'].toString()),
                      subtitle: Text('Hora: ' +
                          documentSnapshot['hora'].toString() +
                          ', Asientos Dsp: ' +
                          documentSnapshot['disponibles'].toString() +
                          ', Tipo: ' +
                          documentSnapshot['tipovuelo'].toString()),
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
// agregar reserva
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}

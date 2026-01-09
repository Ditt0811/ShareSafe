import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy')
        .format(data['createdAt'].toDate());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  data['imageUrl'],
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              infoTile('Deskripsi', data['description']),
              infoTile('Lokasi', data['location']),
              infoTile('Tanggal', date),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

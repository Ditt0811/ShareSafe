import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detailscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Divider(color: Colors.amber, thickness: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== TABS =====
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Di Unggah'),
                Tab(text: 'Di Arsipkan'),
              ],
            ),

            const SizedBox(height: 16),

            // ===== GRID =====
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildGrid(isArchived: false),
                  buildGrid(isArchived: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGrid({required bool isArchived}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('archived', isEqualTo: isArchived)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('Belum ada data',
                style: TextStyle(color: Colors.white54)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(data: data),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

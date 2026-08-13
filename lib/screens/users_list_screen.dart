import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Users List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Stack(
        children: [
          // =========================
          // Background Image
          // =========================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // =========================
          // Blur Effect
          // =========================
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // =========================
          // Dark Overlay
          // =========================
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(
                alpha: 0.45,
              ),
            ),
          ),

          // =========================
          // Users List
          // =========================
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),

              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // No Data
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 80,
                    bottom: 20,
                  ),
                  itemCount: users.length,

                  itemBuilder: (context, index) {
                    final userData =
                        users[index].data()
                            as Map<String, dynamic>;

                    final name =
                        userData['name'] ?? 'No Name';

                    final role =
                        userData['role'] ?? '';

                    final email =
                        userData['email'] ?? '';

                    // Your Firestore field is "contact"
                    final contact =
                        userData['contact'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),

                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                        side: BorderSide(
                          color: Colors.white.withValues(
                            alpha: 0.20,
                          ),
                        ),
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        // =========================
                        // User Avatar
                        // =========================
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.brown,

                          child: Text(
                            name.toString().isNotEmpty
                                ? name
                                    .toString()[0]
                                    .toUpperCase()
                                : '?',

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // =========================
                        // User Name
                        // =========================
                        title: Text(
                          name.toString(),

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // =========================
                        // Role + Email
                        // =========================
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 5,
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                email.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =========================
                        // Contact
                        // =========================
                        trailing: Text(
                          contact.toString(),

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work_rounded,
                size: 90,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                'KosFinder',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi pencarian informasi kos '
                'untuk membantu pengguna menemukan '
                'tempat tinggal yang sesuai.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Identitas Mahasiswa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text('Nama'),
                subtitle: Text('NI PUTU SAPNA MAHARANI'),
              ),
              const ListTile(
                leading: Icon(Icons.badge),
                title: Text('NIM'),
                subtitle: Text('2415051024'),
              ),
              const SizedBox(height: 24),
              const Text(
                'KosFinder - WS11b',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

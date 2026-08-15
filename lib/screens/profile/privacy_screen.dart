import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacidad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Gestión de Datos y Privacidad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'En Pets Alert nos tomamos en serio tu seguridad. Aquí puedes gestionar cómo se utiliza tu información dentro de la comunidad.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text(
              'Ocultar mi correo en reportes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Los usuarios solo podrán contactarte por el chat interno.',
            ),
            value: true,
            onChanged: (bool value) {},
            activeThumbColor: AppColors.primary,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primary),
            title: const Text('Descargar mis datos'),
            subtitle: const Text(
              'Solicita una copia de tus reportes y mensajes (Derechos ARCO).',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_forever, color: AppColors.lost),
              label: const Text(
                'Eliminar mi cuenta permanentemente',
                style: TextStyle(
                  color: AppColors.lost,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.lost),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

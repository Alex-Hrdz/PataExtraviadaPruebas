import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import '../profile/my_reports_screen.dart';
import '../profile/profile_screen.dart';
import '../chat/chat_list_screen.dart'; // <-- Importamos la lista de chats

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pantallas = <Widget>[
    FeedScreen(),
    MyReportsScreen(),
    ChatListScreen(), // <-- Agregamos la pantalla a la lista
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // <-- Necesario cuando hay 4 o más íconos
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mis Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Mensajes', // <-- Nuevo botón
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

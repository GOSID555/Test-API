import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('PHONE')),
      ),
      body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final title_phone = user['title'];
            final des = user['description'];
            final price = user['price'];
            final imageUrl = user['thumbnail'];

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(imageUrl),
              ),
              title: Text(title_phone),
              subtitle: Text(des),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUser,
      ),
    );
  }

  void fetchUser() async {
    print('fetchUsers Call');
    const url = 'https://dummyjson.com/products';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    setState(() {
      users = json['products'];
    });
    print('fetchUser complete');
  }
}

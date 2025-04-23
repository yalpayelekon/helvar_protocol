import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const TcpSimulatorApp());
}

class TcpSimulatorApp extends StatelessWidget {
  const TcpSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TcpSimulatorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TcpSimulatorHomePage extends StatefulWidget {
  const TcpSimulatorHomePage({super.key});

  @override
  State<TcpSimulatorHomePage> createState() => _TcpSimulatorHomePageState();
}

class _TcpSimulatorHomePageState extends State<TcpSimulatorHomePage> {
  final List<_TcpClient> clients = [];
  final List<String> logs = [];
  final int clientCount = 1000;
  bool isStarted = false;
  final TextEditingController msgController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void log(String text) {
    setState(() {
      logs.add(text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  Future<void> startClients() async {
    if (isStarted) return;
    setState(() => isStarted = true);

    for (int i = 0; i < clientCount; i++) {
      final client = _TcpClient(id: i, log: log);
      clients.add(client);
      client.connect();
      await Future.delayed(const Duration(milliseconds: 2));
    }
  }

  void sendToAll(String message) {
    for (var client in clients) {
      client.send(message);
    }
  }

  void sendToOne(int index, String message) {
    if (index >= 0 && index < clients.length) {
      clients[index].send(message);
    }
  }

  @override
  void dispose() {
    for (var client in clients) {
      client.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TCP Client Simulator')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: startClients,
                  child: const Text('Start 1000 Clients'),
                ),
                const SizedBox(width: 20),
                Text(
                  'Active: ${clients.where((c) => c.connected).length}/$clientCount',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => sendToAll(msgController.text),
                  child: const Text('Broadcast'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: logs.length,
                  itemBuilder: (context, index) => Text(logs[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TcpClient {
  final int id;
  final void Function(String) log;
  Socket? _socket;
  bool connected = false;

  _TcpClient({required this.id, required this.log});

  void connect() async {
    try {
      _socket = await Socket.connect('127.0.0.1', 8080);
      connected = true;
      log('[$id] Connected');
      _socket!.listen(
        (data) => log('[$id] ${utf8.decode(data).trim()}'),
        onDone: () => _onDone('done'),
        onError: (e) => _onDone('error: $e'),
      );
    } catch (e) {
      _onDone('connection failed: $e');
    }
  }

  void send(String message) {
    if (_socket != null && connected) {
      _socket!.write('$message\n');
    }
  }

  void _onDone(String msg) {
    connected = false;
    log('[$id] $msg');
    _socket?.destroy();
  }

  void close() {
    _socket?.destroy();
  }
}

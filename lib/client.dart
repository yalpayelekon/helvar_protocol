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
    return MaterialApp(
      title: 'HelvarNet TCP Simulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TcpSimulatorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TcpSimulatorHomePage extends StatefulWidget {
  const TcpSimulatorHomePage({super.key});

  @override
  State<TcpSimulatorHomePage> createState() => _TcpSimulatorHomePageState();
}

class _TcpSimulatorHomePageState extends State<TcpSimulatorHomePage>
    with SingleTickerProviderStateMixin {
  final List<_TcpClient> clients = [];
  final List<String> logs = [];
  final int clientCount = 1000;
  bool isStarted = false;
  final TextEditingController msgController = TextEditingController();
  final TextEditingController customCmdController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late TabController _tabController;

  // Controllers for HelvarNet command parameters
  final TextEditingController groupController = TextEditingController(
    text: '1',
  );
  final TextEditingController blockController = TextEditingController(
    text: '1',
  );
  final TextEditingController sceneController = TextEditingController(
    text: '1',
  );
  final TextEditingController deviceController = TextEditingController(
    text: '1.1.1.1',
  );
  final TextEditingController levelController = TextEditingController(
    text: '50',
  );
  final TextEditingController fadeTimeController = TextEditingController(
    text: '500',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void log(String text) {
    setState(() {
      logs.add(text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> startClients() async {
    if (isStarted) return;
    setState(() => isStarted = true);

    final client = _TcpClient(id: 1, log: log);
    clients.add(client);
    client.connect();
  }

  void sendMessage(String message) {
    if (clients.isEmpty || !clients[0].connected) {
      log('[WARNING] No connected clients');
      return;
    }

    clients[0].send(message);
    msgController.clear();
  }

  // HelvarNet protocol command builders
  String buildRecallSceneGroupCommand() {
    final group = groupController.text;
    final block = blockController.text;
    final scene = sceneController.text;
    final fadeTime = fadeTimeController.text;

    return '>V:1,C:11,G:$group,B:$block,S:$scene,F:$fadeTime#';
  }

  String buildDirectLevelGroupCommand() {
    final group = groupController.text;
    final level = levelController.text;
    final fadeTime = fadeTimeController.text;

    return '>V:1,C:13,G:$group,L:$level,F:$fadeTime#';
  }

  String buildDirectLevelDeviceCommand() {
    final device = deviceController.text;
    final level = levelController.text;
    final fadeTime = fadeTimeController.text;

    return '>V:1,C:14,@$device,L:$level,F:$fadeTime#';
  }

  String buildQueryLoadLevelCommand() {
    final device = deviceController.text;
    return '>V:1,C:152,@$device#';
  }

  String buildQueryGroupCommand() {
    final group = groupController.text;
    return '>V:1,C:105,G:$group#';
  }

  String buildQueryLastSceneCommand() {
    final group = groupController.text;
    return '>V:1,C:109,G:$group#';
  }

  String buildQueryClustersCommand() {
    return '>V:1,C:101#';
  }

  String buildQueryTimeCommand() {
    return '>V:1,C:185#';
  }

  @override
  void dispose() {
    for (var client in clients) {
      client.close();
    }
    _tabController.dispose();
    msgController.dispose();
    customCmdController.dispose();
    groupController.dispose();
    blockController.dispose();
    sceneController.dispose();
    deviceController.dispose();
    levelController.dispose();
    fadeTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HelvarNet TCP Client Simulator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Control Commands'),
            Tab(text: 'Query Commands'),
            Tab(text: 'Custom Commands'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControlCommandsTab(),
          _buildQueryCommandsTab(),
          _buildCustomCommandsTab(),
        ],
      ),
    );
  }

  Widget _buildControlCommandsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildConnectionStatus(),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel - Controls
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Control Parameters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: groupController,
                                  decoration: const InputDecoration(
                                    labelText: 'Group ID',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: blockController,
                                  decoration: const InputDecoration(
                                    labelText: 'Block',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: sceneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Scene',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: deviceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Device Address',
                                    border: OutlineInputBorder(),
                                    hintText: 'e.g. 1.1.1.1',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: levelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Level (0-100%)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: fadeTimeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Fade Time (ms)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    isStarted
                                        ? () => sendMessage(
                                          buildRecallSceneGroupCommand(),
                                        )
                                        : null,
                                child: const Text('Recall Scene (Group)'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    isStarted
                                        ? () => sendMessage(
                                          buildDirectLevelGroupCommand(),
                                        )
                                        : null,
                                child: const Text('Direct Level (Group)'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    isStarted
                                        ? () => sendMessage(
                                          buildDirectLevelDeviceCommand(),
                                        )
                                        : null,
                                child: const Text('Direct Level (Device)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Right panel - Log view
                Expanded(flex: 2, child: _buildLogView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryCommandsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildConnectionStatus(),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel - Controls
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Query Commands',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage(
                                            buildQueryLoadLevelCommand(),
                                          )
                                          : null,
                                  child: const Text('Query Load Level'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage(
                                            buildQueryGroupCommand(),
                                          )
                                          : null,
                                  child: const Text('Query Group Description'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage(
                                            buildQueryLastSceneCommand(),
                                          )
                                          : null,
                                  child: const Text('Query Last Scene'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage(
                                            buildQueryClustersCommand(),
                                          )
                                          : null,
                                  child: const Text('Query Clusters'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage(
                                            buildQueryTimeCommand(),
                                          )
                                          : null,
                                  child: const Text('Query Time'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage('>V:1,C:190#')
                                          : null,
                                  child: const Text('Query Software Version'),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      isStarted
                                          ? () => sendMessage('>V:1,C:102,@1#')
                                          : null,
                                  child: const Text(
                                    'Query Routers (Cluster 1)',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Right panel - Log view
                Expanded(flex: 2, child: _buildLogView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCommandsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildConnectionStatus(),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel - Controls
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Custom HelvarNet Command',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: customCmdController,
                                  decoration: const InputDecoration(
                                    labelText: 'HelvarNet Command',
                                    border: OutlineInputBorder(),
                                    hintText: '>V:1,C:11,G:1,B:1,S:1#',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    isStarted
                                        ? () {
                                          sendMessage(customCmdController.text);
                                          customCmdController.clear();
                                        }
                                        : null,
                                child: const Text('Send Command'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Common HelvarNet Commands',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: ListView(
                              children: [
                                _buildCommandExample(
                                  'Recall Scene (Group)',
                                  '>V:1,C:11,G:1,B:1,S:1,F:500#',
                                  'Recalls scene 1 in block 1 for group 1 with fade time 500ms',
                                ),
                                _buildCommandExample(
                                  'Direct Level (Group)',
                                  '>V:1,C:13,G:1,L:75,F:500#',
                                  'Sets group 1 to 75% with fade time 500ms',
                                ),
                                _buildCommandExample(
                                  'Direct Level (Device)',
                                  '>V:1,C:14,@1.1.1.1,L:50,F:500#',
                                  'Sets device 1.1.1.1 to 50% with fade time 500ms',
                                ),
                                _buildCommandExample(
                                  'Query Last Scene In Block',
                                  '>V:1,C:103,G:1,B:1#',
                                  'Queries the last scene called in block 1 for group 1',
                                ),
                                _buildCommandExample(
                                  'Query Device Type',
                                  '>V:1,C:104,@1.1.1.1#',
                                  'Queries the device type for device 1.1.1.1',
                                ),
                                _buildCommandExample(
                                  'Query Load Level',
                                  '>V:1,C:152,@1.1.1.1#',
                                  'Queries the current level for device 1.1.1.1',
                                ),
                                _buildCommandExample(
                                  'Query Emergency Tests',
                                  '>V:1,C:170,@1.1.1.1#',
                                  'Queries emergency function test time for device 1.1.1.1',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Right panel - Log view
                Expanded(flex: 2, child: _buildLogView()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandExample(
    String title,
    String command,
    String description,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(command, style: const TextStyle(fontFamily: 'monospace')),
          Text(description, style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          customCmdController.text = command;
        },
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: isStarted ? null : startClients,
          child: const Text('Connect to Server'),
        ),
        const SizedBox(width: 20),
        Text(
          'Status: ${isStarted ? (clients.isNotEmpty && clients[0].connected ? "Connected" : "Connecting...") : "Disconnected"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isStarted && clients.isNotEmpty && clients[0].connected
                    ? Colors.green
                    : (isStarted ? Colors.orange : Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildLogView() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.black87,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Communication Log',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: logs.length,
                itemBuilder:
                    (context, index) => Text(
                      logs[index],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color:
                            logs[index].contains('Received:')
                                ? Colors.green[300]
                                : (logs[index].contains('Sent:')
                                    ? Colors.blue[300]
                                    : Colors.white),
                      ),
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
      log('[$id] Connecting to server...');
      _socket = await Socket.connect('127.0.0.1', 8080);
      connected = true;
      log('[$id] Connected to server');

      _socket!.listen(
        (data) {
          final response = utf8.decode(data).trim();
          log('[$id] Received: $response');
        },
        onDone: () => _onDone('Connection closed'),
        onError: (e) => _onDone('Error: $e'),
      );
    } catch (e) {
      _onDone('Connection failed: $e');
    }
  }

  void send(String message) {
    if (_socket != null && connected) {
      log('[$id] Sent: $message');
      _socket!.write('$message\n');
    } else {
      log('[$id] Cannot send: Not connected');
    }
  }

  void _onDone(String msg) {
    connected = false;
    log('[$id] $msg');
    _socket?.destroy();
  }

  void close() {
    if (_socket != null) {
      log('[$id] Closing connection');
      _socket?.destroy();
      connected = false;
    }
  }
}

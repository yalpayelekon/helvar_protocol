import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

void main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 8080);
  print('Server running on ${server.address.address}:${server.port}');

  int clientId = 0;
  server.listen((Socket client) {
    clientId++;
    handleClient(client, clientId);
  });
}

void handleClient(Socket client, int id) {
  print(
    'Client $id connected: ${client.remoteAddress.address}:${client.remotePort}',
  );
  final subscription = client.listen((data) {
    final message = utf8.decode(data).trim();
    print('[$id] Received: $message');
    if (message == 'get_status') {
      client.write('status: OK\n');
    }
  });

  // Periodically send event messages
  final timer = Timer.periodic(Duration(seconds: 3 + Random().nextInt(3)), (_) {
    final event = 'event: client_$id, value: ${Random().nextInt(100)}\n';
    client.write(event);
  });

  client.done.then((_) {
    print('Client $id disconnected.');
    subscription.cancel();
    timer.cancel();
    client.destroy();
  });
}

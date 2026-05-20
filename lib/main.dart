import 'package:flutter/material.dart';

void main() {
  runApp(const CityRideApp());
}

class CityRideApp extends StatelessWidget {
  const CityRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityRide CR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C853)),
      ),
      home: const HomeScreen(),
    );
  }
}

enum ServiceType { moto, pickup, camion }

class ServiceInfo {
  final String name;
  final String emoji;
  final String description;
  final int baseFare;
  final int kmPrice;
  final int minPrice;
  final int minimum;

  const ServiceInfo({
    required this.name,
    required this.emoji,
    required this.description,
    required this.baseFare,
    required this.kmPrice,
    required this.minPrice,
    required this.minimum,
  });
}

const services = {
  ServiceType.moto: ServiceInfo(
    name: 'Moto',
    emoji: '🏍️',
    description: 'Viajes rápidos, mandados y entregas pequeñas',
    baseFare: 800,
    kmPrice: 350,
    minPrice: 80,
    minimum: 1500,
  ),
  ServiceType.pickup: ServiceInfo(
    name: 'Pickup',
    emoji: '🛻',
    description: 'Carga mediana, muebles y mudanzas pequeñas',
    baseFare: 2500,
    kmPrice: 850,
    minPrice: 180,
    minimum: 6000,
  ),
  ServiceType.camion: ServiceInfo(
    name: 'Camión pequeño',
    emoji: '🚚',
    description: 'Carga grande local y transporte comercial',
    baseFare: 5000,
    kmPrice: 1300,
    minPrice: 300,
    minimum: 12000,
  ),
};

class Trip {
  final ServiceType service;
  final String pickup;
  final String destination;
  final int km;
  final int minutes;
  final int price;
  final String status;

  Trip({
    required this.service,
    required this.pickup,
    required this.destination,
    required this.km,
    required this.minutes,
    required this.price,
    required this.status,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  Trip? activeTrip;

  void createTrip(Trip trip) {
    setState(() {
      activeTrip = trip;
      tab = 1;
    });
  }

  void acceptTrip() {
    if (activeTrip == null) return;

    setState(() {
      activeTrip = Trip(
        service: activeTrip!.service,
        pickup: activeTrip!.pickup,
        destination: activeTrip!.destination,
        km: activeTrip!.km,
        minutes: activeTrip!.minutes,
        price: activeTrip!.price,
        status: 'Aceptado por conductor',
      );
    });
  }

  void finishTrip() {
    setState(() {
      activeTrip = null;
      tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClientPage(onCreateTrip: createTrip, activeTrip: activeTrip),
      DriverPage(trip: activeTrip, onAccept: acceptTrip, onFinish: finishTrip),
      AdminPage(trip: activeTrip),
    ];

    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Cliente'),
          NavigationDestination(icon: Icon(Icons.two_wheeler), label: 'Conductor'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

class ClientPage extends StatefulWidget {
  final Function(Trip) onCreateTrip;
  final Trip? activeTrip;

  const ClientPage({
    super.key,
    required this.onCreateTrip,
    required this.activeTrip,
  });

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  ServiceType selected = ServiceType.moto;

  final pickup = TextEditingController(text: 'Centro');
  final destination = TextEditingController(text: 'Destino');
  final km = TextEditingController(text: '5');
  final minutes = TextEditingController(text: '15');

  int calculatePrice() {
    final s = services[selected]!;
    final distance = int.tryParse(km.text) ?? 0;
    final time = int.tryParse(minutes.text) ?? 0;
    final total = s.baseFare + (distance * s.kmPrice) + (time * s.minPrice);
    return total < s.minimum ? s.minimum : total;
  }

  @override
  Widget build(BuildContext context) {
    final price = calculatePrice();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(),
            const SizedBox(height: 18),
            mapBox(),
            const SizedBox(height: 18),
            if (widget.activeTrip != null) TripCard(trip: widget.activeTrip!),
            const SizedBox(height: 18),
            const Text(
              'Elige el tipo de servicio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final entry in services.entries) serviceButton(entry),
            const SizedBox(height: 10),
            input('Salida', pickup, Icons.my_location),
            input('Destino', destination, Icons.location_on),
            Row(
              children: [
                Expanded(child: input('Kilómetros', km, Icons.route, number: true)),
                const SizedBox(width: 10),
                Expanded(child: input('Minutos', minutes, Icons.timer, number: true)),
              ],
            ),
            priceBox(price),
            const SizedBox(height: 18),
            requestButton(price),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CityRide CR',
            style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Moto, pickup y camión pequeño en colones ₡',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget mapBox() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              '🗺️ Mapa GPS próximamente',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Ciudad activa: Costa Rica',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceButton(MapEntry<ServiceType, ServiceInfo> entry) {
    final isSelected = selected == entry.key;

    return GestureDetector(
      onTap: () => setState(() => selected = entry.key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C853) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(entry.value.emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    entry.value.description,
                    style: TextStyle(color: isSelected ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController controller, IconData icon, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget priceBox(int price) {
    final s = services[selected]!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Precio estimado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '₡$price',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00C853),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Base ₡${s.baseFare} · Km ₡${s.kmPrice} · Min ₡${s.minPrice} · Mínimo ₡${s.minimum}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget requestButton(int price) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () {
          widget.onCreateTrip(
            Trip(
              service: selected,
              pickup: pickup.text,
              destination: destination.text,
              km: int.tryParse(km.text) ?? 0,
              minutes: int.tryParse(minutes.text) ?? 0,
              price: price,
              status: 'Buscando conductor',
            ),
          );
        },
        child: const Text(
          'Solicitar servicio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DriverPage extends StatelessWidget {
  final Trip? trip;
  final VoidCallback onAccept;
  final VoidCallback onFinish;

  const DriverPage({
    super.key,
    required this.trip,
    required this.onAccept,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    if (trip == null) {
      return const Center(
        child: Text(
          'No hay solicitudes activas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel Conductor', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            TripCard(trip: trip!),
            const Spacer(),
            button('Aceptar viaje', const Color(0xFF00C853), onAccept),
            const SizedBox(height: 12),
            button('Finalizar viaje', Colors.black, onFinish),
          ],
        ),
      ),
    );
  }

  Widget button(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  final Trip? trip;

  const AdminPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final commission = trip == null ? 0 : (trip!.price * 0.15).round();
    final driverPay = trip == null ? 0 : trip!.price - commission;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel Admin', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            adminBox('Viajes activos', trip == null ? '0' : '1'),
            adminBox('Comisión app 15%', '₡$commission'),
            adminBox('Gana conductor', '₡$driverPay'),
            const SizedBox(height: 20),
            if (trip != null) TripCard(trip: trip!),
          ],
        ),
      ),
    );
  }

  Widget adminBox(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white70))),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF00C853), fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final service = services[trip.service]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${service.emoji} ${service.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Estado: ${trip.status}', style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Salida: ${trip.pickup}'),
          Text('Destino: ${trip.destination}'),
          Text('Distancia: ${trip.km} km'),
          Text('Tiempo: ${trip.minutes} minutos'),
          const SizedBox(height: 12),
          Text(
            'Total: ₡${trip.price}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF00C853)),
          ),
        ],
      ),
    );
  }
}
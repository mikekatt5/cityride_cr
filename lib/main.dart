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
      home: const LoginScreen(),
    );
  }
}

enum UserRole { cliente, conductor, admin }
enum ServiceType { moto, pickup, camion }

class DriverProfile {
  final String name;
  final String vehicle;
  final String plate;
  final bool online;

  const DriverProfile({
    required this.name,
    required this.vehicle,
    required this.plate,
    required this.online,
  });

  DriverProfile copyWith({bool? online}) {
    return DriverProfile(
      name: name,
      vehicle: vehicle,
      plate: plate,
      online: online ?? this.online,
    );
  }
}

class ServiceInfo {
  final String name;
  final String emoji;
  final String description;
  final int baseFare;
  final int kmPrice;
  final int minutePrice;
  final int minimumFare;

  const ServiceInfo({
    required this.name,
    required this.emoji,
    required this.description,
    required this.baseFare,
    required this.kmPrice,
    required this.minutePrice,
    required this.minimumFare,
  });
}

const services = {
  ServiceType.moto: ServiceInfo(
    name: 'Moto',
    emoji: '🏍️',
    description: 'Viajes rápidos y mandados',
    baseFare: 800,
    kmPrice: 350,
    minutePrice: 80,
    minimumFare: 1500,
  ),
  ServiceType.pickup: ServiceInfo(
    name: 'Pickup',
    emoji: '🛻',
    description: 'Carga mediana y mudanzas',
    baseFare: 2500,
    kmPrice: 850,
    minutePrice: 180,
    minimumFare: 6000,
  ),
  ServiceType.camion: ServiceInfo(
    name: 'Camión pequeño',
    emoji: '🚚',
    description: 'Carga comercial local',
    baseFare: 5000,
    kmPrice: 1300,
    minutePrice: 300,
    minimumFare: 12000,
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
  final DriverProfile? driver;

  const Trip({
    required this.service,
    required this.pickup,
    required this.destination,
    required this.km,
    required this.minutes,
    required this.price,
    required this.status,
    this.driver,
  });

  Trip copyWith({String? status, DriverProfile? driver}) {
    return Trip(
      service: service,
      pickup: pickup,
      destination: destination,
      km: km,
      minutes: minutes,
      price: price,
      status: status ?? this.status,
      driver: driver ?? this.driver,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole selectedRole = UserRole.cliente;
  bool isRegister = false;

  final nameController = TextEditingController(text: 'Michael');
  final emailController = TextEditingController(text: 'demo@cityridecr.com');
  final passwordController = TextEditingController(text: '123456');

  String roleName(UserRole role) {
    if (role == UserRole.cliente) return 'Cliente';
    if (role == UserRole.conductor) return 'Conductor';
    return 'Admin';
  }

  IconData roleIcon(UserRole role) {
    if (role == UserRole.cliente) return Icons.person;
    if (role == UserRole.conductor) return Icons.two_wheeler;
    return Icons.admin_panel_settings;
  }

  void enterApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userName: nameController.text.trim().isEmpty ? 'Usuario' : nameController.text.trim(),
          userRole: selectedRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CityRide CR',
                style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Moto, pickup y camión pequeño en Costa Rica',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRegister ? 'Crear cuenta' : 'Iniciar sesión',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const Text('Selecciona cómo quieres entrar', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        roleButton(UserRole.cliente),
                        const SizedBox(width: 8),
                        roleButton(UserRole.conductor),
                        const SizedBox(width: 8),
                        roleButton(UserRole.admin),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (isRegister) input('Nombre', nameController, Icons.badge, false),
                    input('Correo', emailController, Icons.email, false),
                    input('Contraseña', passwordController, Icons.lock, true),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: enterApp,
                        child: Text(
                          isRegister
                              ? 'Registrarme como ${roleName(selectedRole)}'
                              : 'Entrar como ${roleName(selectedRole)}',
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => isRegister = !isRegister),
                        child: Text(isRegister ? 'Ya tengo cuenta' : 'Crear cuenta nueva'),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleButton(UserRole role) {
    final selected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF00C853) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(roleIcon(role), color: selected ? Colors.white : Colors.black),
              Text(
                roleName(role),
                style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget input(String label, TextEditingController controller, IconData icon, bool obscure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  final UserRole userRole;

  const HomeScreen({super.key, required this.userName, required this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  Trip? activeTrip;
  final List<Trip> completedTrips = [];

  DriverProfile driver = const DriverProfile(
    name: 'Conductor CityRide',
    vehicle: 'Moto / Pickup / Camión',
    plate: 'CR-2026',
    online: true,
  );

  @override
  void initState() {
    super.initState();
    tab = widget.userRole == UserRole.cliente ? 0 : widget.userRole == UserRole.conductor ? 1 : 2;
  }

  void createTrip(Trip trip) {
    setState(() {
      activeTrip = trip;
      tab = 1;
    });
  }

  void toggleDriverOnline() {
    setState(() {
      driver = driver.copyWith(online: !driver.online);
    });
  }

  void acceptTrip() {
    if (activeTrip == null || !driver.online) return;

    setState(() {
      activeTrip = activeTrip!.copyWith(
        status: 'Aceptado por conductor',
        driver: driver,
      );
    });
  }

  void finishTrip() {
    if (activeTrip != null) {
      completedTrips.add(activeTrip!.copyWith(status: 'Completado'));
    }

    setState(() {
      activeTrip = null;
      tab = 0;
    });
  }

  void logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClientPage(
        userName: widget.userName,
        onCreateTrip: createTrip,
        activeTrip: activeTrip,
        driver: driver,
        onLogout: logout,
      ),
      DriverPage(
        userName: widget.userName,
        trip: activeTrip,
        history: completedTrips,
        driver: driver,
        onToggleOnline: toggleDriverOnline,
        onAccept: acceptTrip,
        onFinish: finishTrip,
        onLogout: logout,
      ),
      AdminPage(
        userName: widget.userName,
        trip: activeTrip,
        history: completedTrips,
        driver: driver,
        onLogout: logout,
      ),
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
  final String userName;
  final Function(Trip) onCreateTrip;
  final Trip? activeTrip;
  final DriverProfile driver;
  final VoidCallback onLogout;

  const ClientPage({
    super.key,
    required this.userName,
    required this.onCreateTrip,
    required this.activeTrip,
    required this.driver,
    required this.onLogout,
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
    final total = s.baseFare + (distance * s.kmPrice) + (time * s.minutePrice);
    return total < s.minimumFare ? s.minimumFare : total;
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
            topBar('CityRide CR', 'Hola, ${widget.userName}', widget.onLogout),
            const SizedBox(height: 18),
            mapBox(),
            const SizedBox(height: 18),
            driverStatusCard(widget.driver),
            const SizedBox(height: 18),
            if (widget.activeTrip != null) TripCard(trip: widget.activeTrip!),
            const SizedBox(height: 18),
            const Text('Elige el tipo de servicio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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

  Widget mapBox() {
    return Container(
      height: 220,
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(26)),
      child: const Center(
        child: Text(
          '🗺️ Mapa GPS próximamente',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ]),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget priceBox(int price) {
    final s = services[selected]!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Precio estimado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Text(
                '₡$price',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF00C853)),
              ),
            ],
          ),
          Text(
            'Base ₡${s.baseFare} · Km ₡${s.kmPrice} · Min ₡${s.minutePrice} · Mínimo ₡${s.minimumFare}',
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
          backgroundColor: widget.driver.online ? Colors.black : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: widget.driver.online
            ? () {
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
              }
            : null,
        child: Text(
          widget.driver.online ? 'Solicitar servicio' : 'No hay conductores disponibles',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DriverPage extends StatelessWidget {
  final String userName;
  final Trip? trip;
  final List<Trip> history;
  final DriverProfile driver;
  final VoidCallback onToggleOnline;
  final VoidCallback onAccept;
  final VoidCallback onFinish;
  final VoidCallback onLogout;

  const DriverPage({
    super.key,
    required this.userName,
    required this.trip,
    required this.history,
    required this.driver,
    required this.onToggleOnline,
    required this.onAccept,
    required this.onFinish,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final totalGanado = history.fold<int>(0, (sum, t) => sum + (t.price * 0.85).round());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            topBar('Panel Conductor', userName, onLogout),
            const SizedBox(height: 14),
            driverPanelCard(driver, onToggleOnline),
            const SizedBox(height: 14),
            metricBox('Ganancia acumulada', '₡$totalGanado'),
            metricBox('Viajes completados', '${history.length}'),
            const SizedBox(height: 20),
            if (trip == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('No hay solicitudes activas'),
                ),
              )
            else ...[
              TripCard(trip: trip!),
              const SizedBox(height: 14),
              button(
                driver.online ? 'Aceptar viaje' : 'Activa disponible para aceptar',
                driver.online ? const Color(0xFF00C853) : Colors.grey,
                driver.online ? onAccept : null,
              ),
              const SizedBox(height: 12),
              button('Finalizar viaje', Colors.black, onFinish),
            ],
            const SizedBox(height: 20),
            historyList(history),
          ],
        ),
      ),
    );
  }

  Widget button(String text, Color color, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  final String userName;
  final Trip? trip;
  final List<Trip> history;
  final DriverProfile driver;
  final VoidCallback onLogout;

  const AdminPage({
    super.key,
    required this.userName,
    required this.trip,
    required this.history,
    required this.driver,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final totalVentas = history.fold<int>(0, (sum, t) => sum + t.price);
    final totalComision = history.fold<int>(0, (sum, t) => sum + (t.price * 0.15).round());
    final driverPay = trip == null ? 0 : trip!.price - (trip!.price * 0.15).round();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            topBar('Panel Admin', userName, onLogout),
            const SizedBox(height: 14),
            driverStatusCard(driver),
            const SizedBox(height: 14),
            metricBox('Conductores online', driver.online ? '1' : '0'),
            metricBox('Viajes activos', trip == null ? '0' : '1'),
            metricBox('Viajes completados', '${history.length}'),
            metricBox('Ventas totales', '₡$totalVentas'),
            metricBox('Comisión app 15%', '₡$totalComision'),
            if (trip != null) metricBox('Ganancia conductor viaje activo', '₡$driverPay'),
            const SizedBox(height: 20),
            if (trip != null) TripCard(trip: trip!),
            const SizedBox(height: 20),
            historyList(history),
          ],
        ),
      ),
    );
  }
}

Widget topBar(String title, String subtitle, VoidCallback onLogout) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
    child: Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        IconButton(onPressed: onLogout, icon: const Icon(Icons.logout, color: Colors.white)),
      ],
    ),
  );
}

Widget driverStatusCard(DriverProfile driver) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: driver.online ? const Color(0xFF00C853) : Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text('${driver.vehicle} · Placa ${driver.plate}', style: const TextStyle(color: Colors.black54)),
          ]),
        ),
        Text(
          driver.online ? 'ONLINE' : 'OFFLINE',
          style: TextStyle(
            color: driver.online ? const Color(0xFF00C853) : Colors.grey,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

Widget driverPanelCard(DriverProfile driver, VoidCallback onToggle) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Estado del conductor', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text(driver.online ? 'Disponible para recibir viajes' : 'No disponible'),
          ]),
        ),
        Switch(
          value: driver.online,
          activeColor: const Color(0xFF00C853),
          onChanged: (_) => onToggle(),
        ),
      ],
    ),
  );
}

Widget metricBox(String title, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(value, style: const TextStyle(color: Color(0xFF00C853), fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

Widget historyList(List<Trip> history) {
  if (history.isEmpty) {
    return const Text('Sin historial todavía', style: TextStyle(color: Colors.black54));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Historial de viajes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      for (final trip in history.reversed) TripCard(trip: trip),
    ],
  );
}

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final service = services[trip.service]!;
    final commission = (trip.price * 0.15).round();
    final driverPay = trip.price - commission;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${service.emoji} ${service.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text('Estado: ${trip.status}', style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
          if (trip.driver != null) ...[
            const SizedBox(height: 8),
            Text('Conductor: ${trip.driver!.name}'),
            Text('Vehículo: ${trip.driver!.vehicle}'),
            Text('Placa: ${trip.driver!.plate}'),
          ],
          const SizedBox(height: 10),
          Text('Salida: ${trip.pickup}'),
          Text('Destino: ${trip.destination}'),
          Text('Distancia: ${trip.km} km'),
          Text('Tiempo: ${trip.minutes} minutos'),
          const SizedBox(height: 10),
          Text('Total: ₡${trip.price}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text('Comisión app: ₡$commission'),
          Text('Conductor gana: ₡$driverPay'),
        ],
      ),
    );
  }
}
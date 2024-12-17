import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic>? _selectedProduct;
  List<Map<String, dynamic>> _warehouses = [];
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _getUserLocation();
  }

  Future<void> _fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      setState(() {
        _products = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> _fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productId).get();
      QuerySnapshot warehouseSnapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('warehouses')
          .get();

      setState(() {
        _selectedProduct = {
          'id': productId,
          ...productSnapshot.data() as Map<String, dynamic>,
        };
        _warehouses = warehouseSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'stock': data['stock'] ?? 0,
            'latitude': (data['latitude'] is String)
                ? double.parse(data['latitude'])
                : data['latitude'] as double,
            'longitude': (data['longitude'] is String)
                ? double.parse(data['longitude'])
                : data['longitude'] as double,
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  Future<void> _getUserLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permissions are denied.");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permissions are permanently denied.");
    return;
  }

  try {
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _userLocation = position;
    });
  } catch (e) {
    print("Error getting location: $e");
  }
}

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) {
      return double.infinity;
    }
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Future<void> _openGoogleMaps(double destLatitude, double destLongitude) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=$destLatitude,$destLongitude";

    // ignore: deprecated_member_use
    if (await canLaunch(googleMapsUrl)) {
      // ignore: deprecated_member_use
      await launch(googleMapsUrl);
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Pilih Produk",
                        border: OutlineInputBorder(),
                      ),
                      items: _products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product['id'],
                          child: Text(product['name'] ?? "Tanpa Nama"),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          _fetchProductDetails(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_selectedProduct != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        image: DecorationImage(
                          image: NetworkImage(
                            _selectedProduct?['imageUrl'] ??
                                'https://via.placeholder.com/100',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedProduct?['description'] ??
                            "Deskripsi tidak tersedia.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
              if (_warehouses.isNotEmpty && _userLocation != null) ...[
                ..._warehouses.map((warehouse) {
                  double distance = _calculateDistance(
                    _userLocation!.latitude,
                    _userLocation!.longitude,
                    warehouse['latitude'] ?? 0.0,
                    warehouse['longitude'] ?? 0.0,
                  );

                  return Card(
                    child: ListTile(
                      title:
                          Text(warehouse['name'] ?? "Gudang Tidak Diketahui"),
                      subtitle: Text(
                          "Stok: ${warehouse['stock'] ?? "Tidak tersedia"}"),
                      trailing: Text("${distance.toStringAsFixed(1)} km"),
                      onTap: () {
                        _openGoogleMaps(
                          warehouse['latitude'] ?? 0.0,
                          warehouse['longitude'] ?? 0.0,
                        );
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

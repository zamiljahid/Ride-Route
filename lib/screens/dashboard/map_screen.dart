import 'package:delivary/api/api_client.dart';
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared_preference.dart';
import 'model/store_location_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StoreLocationModel> _storeLocations = [];
  List<StoreLocationModel> _filteredStoreLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStores() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStoreLocations = _storeLocations
          .where((store) => store.name?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }


  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    print('Google Maps URL: $googleMapsUrl');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } else {
        throw 'Could not open Google Maps.';
      }
    } catch (e) {
      print("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Store Location',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Modern Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search for store...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
          ),

          // FutureBuilder for Store Locations
          Expanded(
            child: FutureBuilder<List<StoreLocationModel>?>(
              future: ApiClient()
                  .getStoreLocation('${SharedPrefs.getString('token')}'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No store locations available.'));
                } else {
                  // Set the store locations and filter only after data is fetched
                  if (_storeLocations.isEmpty) {
                    _storeLocations = snapshot.data!;
                    _filteredStoreLocations =
                        _storeLocations; // Set the initial filtered list
                  }
                  return ListView.builder(
                    itemCount: _filteredStoreLocations.length,
                    itemBuilder: (context, index) {
                      final store = _filteredStoreLocations[index];

                      return GestureDetector(
                        onTap: (){
                          print("object");
                          final lat = double.tryParse(store.latitude ?? '');
                          final lng =
                          double.tryParse(store.longitude ?? '');
                          if (lat != null && lng != null) {
                            _openGoogleMaps(lat, lng);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Invalid location for this store.')),
                            );
                          }
                        },
                        child: Card(
                          color: CustomColors.customeBlue,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              store.name ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Rowdies',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            trailing: Icon(Icons.location_on_outlined,
                                  color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

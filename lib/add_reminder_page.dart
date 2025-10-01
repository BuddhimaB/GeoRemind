import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _radiusController = TextEditingController(text: '100');

  String _selectedCategory = 'Work';
  bool _isHighPriority = false;
  double _selectedRadius = 100;

  final List<String> _categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Travel',
    'Social',
    'Other',
  ];

  final List<Map<String, dynamic>> _suggestedLocations = [
    {
      'name': 'Home',
      'address': '123 Main Street, New York, NY',
      'lat': 40.7128,
      'lng': -74.0060,
      'icon': Icons.home,
    },
    {
      'name': 'Work',
      'address': '456 Business Ave, New York, NY',
      'lat': 40.7589,
      'lng': -73.9851,
      'icon': Icons.work,
    },
    {
      'name': 'Grocery Store',
      'address': 'Walmart Supercenter, Broadway',
      'lat': 40.7505,
      'lng': -73.9934,
      'icon': Icons.shopping_cart,
    },
    {
      'name': 'Gym',
      'address': 'Planet Fitness, 5th Avenue',
      'lat': 40.7532,
      'lng': -73.9822,
      'icon': Icons.fitness_center,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Reminder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Reminder Details'),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Location Settings'),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildSuggestedLocations(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Trigger Settings'),
              const SizedBox(height: 16),
              _buildRadiusSlider(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Options'),
              const SizedBox(height: 16),
              _buildPrioritySwitch(),
              const SizedBox(height: 32),
              
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Reminder Title',
        hintText: 'e.g., Pick up groceries',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add more details about this reminder...',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Search for a place or enter address',
        prefixIcon: const Icon(Icons.location_on),
        suffixIcon: IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: _useCurrentLocation,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a location';
        }
        return null;
      },
    );
  }

  Widget _buildSuggestedLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestedLocations.length,
            itemBuilder: (context, index) {
              final location = _suggestedLocations[index];
              return GestureDetector(
                onTap: () => _selectSuggestedLocation(location),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        location['icon'],
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trigger Radius:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_selectedRadius.round()}m',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedRadius,
          min: 25,
          max: 500,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              _selectedRadius = value;
              _radiusController.text = value.round().toString();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '25m',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '500m',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'High Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Send persistent notifications',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Switch(
          value: _isHighPriority,
          onChanged: (value) {
            setState(() {
              _isHighPriority = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Create Reminder',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _useCurrentLocation() {
    // In a real app, this would use location services
    setState(() {
      _locationController.text = 'Current Location (40.7128, -74.0060)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Using current location'),
      ),
    );
  }

  void _selectSuggestedLocation(Map<String, dynamic> location) {
    setState(() {
      _locationController.text = location['name'];
    });
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      // In a real app, this would save to database/backend
      
      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your reminder has been created:'),
                const SizedBox(height: 12),
                Text('• Title: ${_titleController.text}'),
                Text('• Location: ${_locationController.text}'),
                Text('• Category: $_selectedCategory'),
                Text('• Radius: ${_selectedRadius.round()}m'),
                if (_isHighPriority) const Text('• High Priority: Yes'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
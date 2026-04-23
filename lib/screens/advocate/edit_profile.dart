import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/advocate_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final locationCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final divisionCtrl = TextEditingController();
  final practiceAreasCtrl = TextEditingController(); // comma separated
  final bioCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final courtNameCtrl = TextEditingController();
  final barNumberCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  File? _selectedPhoto;
  String? _existingPhotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔥 LOAD EXISTING PROFILE
  Future<void> _loadProfile() async {
    try {
      final profile = await AdvocateService.getMyProfile();
      setState(() {
        locationCtrl.text = profile['location'] ?? '';
        districtCtrl.text = profile['district'] ?? '';
        divisionCtrl.text = profile['division'] ?? '';
        practiceAreasCtrl.text = (profile['practice_areas'] is List
            ? (profile['practice_areas'] as List).join(', ')
            : profile['practice_areas'] ?? '');
        bioCtrl.text = profile['bio'] ?? '';
        experienceCtrl.text = profile['experience_years']?.toString() ?? '';
        courtNameCtrl.text = profile['court_name'] ?? '';
        barNumberCtrl.text = profile['bar_number'] ?? '';
        phoneCtrl.text = profile['phone'] ?? '';
        _existingPhotoUrl = profile['photo_url'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not load profile: $e")));
      }
    }
  }

  // 🔥 PICK PHOTO
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = File(picked.path));
    }
  }

  // 🔥 SAVE PROFILE
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await AdvocateService.updateProfile(
        fields: {
          'location': locationCtrl.text.trim(),
          'district': districtCtrl.text.trim(),
          'division': divisionCtrl.text.trim(),
          'practice_areas': practiceAreasCtrl.text.trim(),
          'bio': bioCtrl.text.trim(),
          'experience_years': experienceCtrl.text.trim(),
          'court_name': courtNameCtrl.text.trim(),
          'bar_number': barNumberCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
        },
        photo: _selectedPhoto,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: $e")));
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              "Edit My Profile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Update your advocate profile information",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // PHOTO SECTION
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    backgroundImage: _selectedPhoto != null
                        ? FileImage(_selectedPhoto!)
                        : (_existingPhotoUrl != null
                                  ? NetworkImage(
                                      "http://10.0.2.2:5000${_existingPhotoUrl!}",
                                    )
                                  : null)
                              as ImageProvider?,
                    child: (_selectedPhoto == null && _existingPhotoUrl == null)
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.green,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // SECTION: Personal Info
            _sectionTitle("Personal Info"),
            _field(phoneCtrl, "Phone Number", Icons.phone, hint: "01XXXXXXXXX"),
            _field(
              barNumberCtrl,
              "Bar Registration Number",
              Icons.badge,
              hint: "e.g. BD-12345",
            ),
            _field(
              experienceCtrl,
              "Years of Experience",
              Icons.work,
              hint: "e.g. 5",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // SECTION: Location
            _sectionTitle("Location"),
            _field(
              locationCtrl,
              "Location / Area",
              Icons.location_on,
              hint: "e.g. Motijheel, Dhaka",
            ),
            _field(districtCtrl, "District", Icons.map, hint: "e.g. Dhaka"),
            _field(
              divisionCtrl,
              "Division",
              Icons.account_balance,
              hint: "e.g. Dhaka Division",
            ),
            _field(
              courtNameCtrl,
              "Court Name",
              Icons.gavel,
              hint: "e.g. Dhaka High Court",
            ),

            const SizedBox(height: 20),

            // SECTION: Professional Info
            _sectionTitle("Professional Info"),
            _field(
              practiceAreasCtrl,
              "Practice Areas",
              Icons.gavel,
              hint: "e.g. Civil, Criminal, Family",
              helperText: "Separate multiple areas with commas",
            ),
            _bioField(),

            const SizedBox(height: 32),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: required
            ? (v) => (v == null || v.isEmpty) ? "$label is required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          prefixIcon: Icon(icon, color: Colors.green, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _bioField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: bioCtrl,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "Bio / About",
          hintText: "Tell clients about your experience and expertise...",
          alignLabelWithHint: true,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.description, color: Colors.green, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    locationCtrl.dispose();
    districtCtrl.dispose();
    divisionCtrl.dispose();
    practiceAreasCtrl.dispose();
    bioCtrl.dispose();
    experienceCtrl.dispose();
    courtNameCtrl.dispose();
    barNumberCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }
}

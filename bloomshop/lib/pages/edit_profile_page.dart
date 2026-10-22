import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/utils/ui_helpers.dart';
import 'package:bloomshop/core/utils/validators.dart';
import 'package:bloomshop/models/user_profile.dart';
import 'package:bloomshop/providers/profile_provider.dart';
import 'package:bloomshop/widgets/primary_button.dart';
import 'package:bloomshop/widgets/profile_avatar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final ImagePicker _picker = ImagePicker();

  /// Newly picked photo (base64) that has not been saved yet.
  String? _newPhotoBase64;
  bool _removePhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Photo shown in the preview, combining the saved one and pending changes.
  UserProfile? _previewProfile(UserProfile? saved) {
    if (saved == null) return null;
    if (_removePhoto) return saved.copyWith(clearPhoto: true);
    if (_newPhotoBase64 != null) {
      return saved.copyWith(photoBase64: _newPhotoBase64);
    }
    return saved;
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      // Bytes (not a file path) so it also works on Flutter Web reloads.
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _newPhotoBase64 = base64Encode(bytes);
        _removePhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, 'Could not open the photo gallery');
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final provider = context.read<ProfileProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await provider.update(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      photoBase64: _newPhotoBase64,
      clearPhoto: _removePhoto,
    );
    showAppSnackBarOn(messenger, 'Profile updated');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final saved =
        context.select<ProfileProvider, UserProfile?>((p) => p.profile);
    final preview = _previewProfile(saved);
    final hasPhoto = preview?.hasPhoto ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        ProfileAvatar(profile: preview, radius: 56),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: AppColors.mutedRose,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _pickPhoto,
                              child: const Padding(
                                padding: EdgeInsets.all(9),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: hasPhoto
                          ? () => setState(() {
                                _newPhotoBase64 = null;
                                _removePhoto = true;
                              })
                          : _pickPhoto,
                      child: Text(hasPhoto ? 'Remove photo' : 'Choose photo'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: saved?.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Shipping address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: Validators.address,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Save Changes',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

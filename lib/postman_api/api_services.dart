import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kids_republik/utils/const.dart';
import 'package:http_parser/http_parser.dart';
import 'package:snackbar/snackbar.dart';

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService({required this.baseUrl, required this.apiKey});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  Future<User> login(String email, String password) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/login?email=$email&password=$password'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
          snack('Logged In Successfully');
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login');
    }
  }

  uploadimage(imagefile) async {
    final response = await http.post(
      Uri.parse('$baseUrl/?file=$imagefile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
          snack('Image uploaded successfully${data}');
    } else {
      throw Exception('Failed to upload $response');
    }
  }

  Future<dynamic> createActivity({
    required String title,
    required String description,
    required String studentId,
    required String staffId,
    required String imagePath,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/student-activity'));

    request.headers['Authorization'] = 'Bearer $apiKey';

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['student_id'] = studentId;
    request.fields['staff_id'] = staffId;

    request.files.add(await http.MultipartFile.fromPath(
      'images',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await http.Response.fromStream(response);
      return json.decode(responseBody.body);
    } else {
      throw Exception('Failed to create activity');
    }
  }

  Future<dynamic> getAllActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-activities'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<dynamic> getActivityByStudentId(String studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-activity?student_id=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load activity');
    }
  }

  Future<dynamic> updateActivityStatus(String postId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-activity/status?post_id=$postId'),
      headers: headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update activity status');
    }
  }

  Future<dynamic> deleteActivity(String postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/student-activity?post_id=$postId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete activity');
    }
  }
}


class CreateActivityPage extends StatefulWidget {
  final ApiService apiService;

  CreateActivityPage({required this.apiService});

  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _staffIdController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _createActivity() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.apiService.createActivity(
          title: _titleController.text,
          description: _descriptionController.text,
          studentId: _studentIdController.text,
          staffId: _staffIdController.text,
          imagePath: _image!.path,
        );
        snack('Activity created successfully!');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Activity created successfully!')),
        // );
      } catch (e) {
        snack('Failed to create activity: $e');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to create activity: $e')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kWhite,
        backgroundColor: kprimary,
        title: Text('Create New Activity',style: TextStyle(fontSize: 14),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _studentIdController,
                decoration: InputDecoration(labelText: 'Student ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a student ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _staffIdController,
                decoration: InputDecoration(labelText: 'Staff ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a staff ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('No image selected.')
                  : Container(height: 200, width: 200,child: Image.file(_image!)),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createActivity,
                child: Text('Create Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final String role;
  // final List<String> permissions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.role,
    // required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
      role: json['role'],
      // permissions: List<String>.from(json['permissions']),
    );
  }
}

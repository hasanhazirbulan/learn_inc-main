import 'package:flutter/material.dart';

class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({Key? key}) : super(key: key);

  @override
  _ManageClassesScreenState createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  final List<String> _classes = ["Math 101", "Physics 202", "Chemistry 303"];

  final TextEditingController _classNameController = TextEditingController();

  void _addClass() {
    if (_classNameController.text.isNotEmpty) {
      setState(() {
        _classes.add(_classNameController.text.trim());
      });
      _classNameController.clear();
      Navigator.of(context).pop();
    }
  }

  void _deleteClass(int index) {
    setState(() {
      _classes.removeAt(index);
    });
  }

  void _showAddClassModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                "Add New Class",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _classNameController,
                decoration: InputDecoration(
                  labelText: "Class Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addClass,
                child: const Text("Add Class"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Classes"),
        backgroundColor: const Color(0xFF4DD0E1),
      ),
      body: _classes.isEmpty
          ? const Center(
        child: Text(
          "No classes available. Add a class to get started!",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                _classes[index],
                style: const TextStyle(fontSize: 16),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteClass(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassModal,
        backgroundColor: const Color(0xFF4DD0E1),
        child: const Icon(Icons.add),
      ),
    );
  }
}

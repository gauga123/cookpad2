import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class RecipeForm extends StatefulWidget {
  final Function(RecipeModel) onSubmit;
  final RecipeModel? initialRecipe;
  final bool isRequest;

  const RecipeForm({
    super.key,
    required this.onSubmit,
    this.initialRecipe,
    this.isRequest = false,
  });

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _stepControllers = [
    TextEditingController()
  ];
  int _diet = 0;
  String _time = '00:00';
  final AuthService _authService = AuthService();
  final _youtubeLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipe != null) {
      _nameController.text = widget.initialRecipe!.name;
      _imageUrlController.text = widget.initialRecipe!.imageUrl;
      _descriptionController.text = widget.initialRecipe!.description;
      _diet = widget.initialRecipe!.diet;
      _time = widget.initialRecipe!.time;
      _youtubeLinkController.text = widget.initialRecipe!.youtubeLink;

      _ingredientControllers.clear();
      for (var ingredient in widget.initialRecipe!.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }

      _stepControllers.clear();
      for (var step in widget.initialRecipe!.steps) {
        _stepControllers.add(TextEditingController(text: step));
      }
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _youtubeLinkController,
              decoration: const InputDecoration(labelText: 'YouTube Link'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _diet,
              decoration: const InputDecoration(labelText: 'Diet Type'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Regular')),
                DropdownMenuItem(value: 1, child: Text('Vegetarian')),
                DropdownMenuItem(value: 2, child: Text('Vegan')),
                DropdownMenuItem(value: 3, child: Text('Gluten-Free')),
              ],
              onChanged: (value) {
                setState(() {
                  _diet = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Cooking Time'),
              subtitle: Text(_time),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(_time.split(':')[0]),
                    minute: int.parse(_time.split(':')[1]),
                  ),
                );
                if (time != null) {
                  setState(() {
                    _time =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Ingredients', style: TextStyle(fontSize: 18)),
            ...List.generate(_ingredientControllers.length, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Ingredient ${index + 1}',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an ingredient';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeIngredient(index),
                  ),
                ],
              );
            }),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 16),
            const Text('Steps', style: TextStyle(fontSize: 18)),
            ...List.generate(_stepControllers.length, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stepControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Step ${index + 1}',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a step';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeStep(index),
                  ),
                ],
              );
            }),
            TextButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final recipe = RecipeModel(
                    name: _nameController.text,
                    imageUrl: _imageUrlController.text,
                    diet: _diet,
                    time: _time,
                    description: _descriptionController.text,
                    ingredients: _ingredientControllers
                        .map((controller) => controller.text)
                        .toList(),
                    steps: _stepControllers
                        .map((controller) => controller.text)
                        .toList(),
                    createdAt: Timestamp.fromDate(DateTime.now()),
                    status: widget.isRequest ? 'pending' : 'approved',
                    authorId: _authService.currentUser?.uid,
                    authorEmail: _authService.currentUser?.email,
                    youtubeLink: _youtubeLinkController.text,
                  );
                  widget.onSubmit(recipe);
                }
              },
              child: Text(widget.isRequest ? 'Send Request' : 'Submit Recipe'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    _youtubeLinkController.dispose();
    super.dispose();
  }
}

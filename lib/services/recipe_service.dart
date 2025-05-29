import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final CollectionReference _recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  // Create a new recipe
  Future<void> createRecipe(RecipeModel recipe) async {
    await _recipesCollection.add(recipe.toMap());
  }

  // Update an existing recipe
  Future<void> updateRecipe(String id, RecipeModel recipe) async {
    await _recipesCollection.doc(id).update(recipe.toMap());
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    await _recipesCollection.doc(id).delete();
  }

  // Get all recipes
  Stream<List<RecipeModel>> getRecipes() {
    return _recipesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get a single recipe by ID
  Future<RecipeModel?> getRecipeById(String id) async {
    final doc = await _recipesCollection.doc(id).get();
    if (doc.exists) {
      return RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get recipes by author
  Stream<List<RecipeModel>> getRecipesByAuthor(String authorId) {
    return _recipesCollection
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get public recipes
  Stream<List<RecipeModel>> getPublicRecipes() {
    return _recipesCollection
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get pending recipe requests
  Stream<List<RecipeModel>> getPendingRecipes() {
    return _recipesCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Update recipe status (for admin)
  Future<void> updateRecipeStatus(String id, String status) async {
    await _recipesCollection.doc(id).update({
      'status': status,
      'isPublic': status == 'approved',
    });
  }

  // Add a comment to a recipe
  Future<void> addComment(String recipeId, Comment comment) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe != null) {
        final updatedComments = [...recipe.comments, comment];
        await _recipesCollection.doc(recipeId).update({
          'comments': updatedComments.map((c) => c.toMap()).toList(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Search recipes
  Stream<List<RecipeModel>> searchRecipes(String query) {
    return _recipesCollection
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final recipes = snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      return recipes.where((recipe) {
        final name = recipe.name.toLowerCase();
        final description = recipe.description.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            recipe.ingredients.any(
                (ingredient) => ingredient.toLowerCase().contains(searchQuery));
      }).toList();
    });
  }

  // Save a recipe for a user
  Future<void> saveRecipe(String userId, String recipeId) async {
    final userSavedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_recipes');

    await userSavedRecipesRef.doc(recipeId).set({
      'savedAt': Timestamp.now(),
    });
  }

  // Remove a saved recipe for a user
  Future<void> removeSavedRecipe(String userId, String recipeId) async {
    final userSavedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_recipes');

    await userSavedRecipesRef.doc(recipeId).delete();
  }

  // Get saved recipes for a user
  Stream<List<RecipeModel>> getSavedRecipes(String userId) {
    final userSavedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_recipes');

    return userSavedRecipesRef.snapshots().asyncMap((snapshot) async {
      final savedRecipeIds = snapshot.docs.map((doc) => doc.id).toList();
      if (savedRecipeIds.isEmpty) return [];

      final savedRecipes = await Future.wait(
        savedRecipeIds.map((id) => getRecipeById(id)),
      );

      return savedRecipes.whereType<RecipeModel>().toList();
    });
  }

  // Check if a recipe is saved by a user
  Stream<bool> isRecipeSaved(String userId, String recipeId) {
    final userSavedRecipesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_recipes');

    return userSavedRecipesRef
        .doc(recipeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Like a recipe
  Future<void> likeRecipe(String userId, String recipeId) async {
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) return;

    final likes = List<String>.from(recipe.likes);
    final dislikes = List<String>.from(recipe.dislikes);

    // Remove from dislikes if exists
    if (dislikes.contains(userId)) {
      dislikes.remove(userId);
    }

    // Add to likes if not already liked
    if (!likes.contains(userId)) {
      likes.add(userId);
    }

    await _recipesCollection.doc(recipeId).update({
      'likes': likes,
      'dislikes': dislikes,
    });
  }

  // Dislike a recipe
  Future<void> dislikeRecipe(String userId, String recipeId) async {
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) return;

    final likes = List<String>.from(recipe.likes);
    final dislikes = List<String>.from(recipe.dislikes);

    // Remove from likes if exists
    if (likes.contains(userId)) {
      likes.remove(userId);
    }

    // Add to dislikes if not already disliked
    if (!dislikes.contains(userId)) {
      dislikes.add(userId);
    }

    await _recipesCollection.doc(recipeId).update({
      'likes': likes,
      'dislikes': dislikes,
    });
  }

  // Remove like/dislike from a recipe
  Future<void> removeRating(String userId, String recipeId) async {
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) return;

    final likes = List<String>.from(recipe.likes);
    final dislikes = List<String>.from(recipe.dislikes);

    likes.remove(userId);
    dislikes.remove(userId);

    await _recipesCollection.doc(recipeId).update({
      'likes': likes,
      'dislikes': dislikes,
    });
  }

  // Get user's rating for a recipe
  Stream<String?> getUserRating(String userId, String recipeId) {
    return _recipesCollection.doc(recipeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);

      if (likes.contains(userId)) return 'like';
      if (dislikes.contains(userId)) return 'dislike';
      return null;
    });
  }

  // Get popular recipes (most viewed)
  Stream<List<RecipeModel>> getPopularRecipes() {
    return _recipesCollection
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: 'approved')
        .orderBy('views', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Increment recipe views
  Future<void> incrementRecipeViews(String recipeId) async {
    await _recipesCollection.doc(recipeId).update({
      'views': FieldValue.increment(1),
    });
  }
}

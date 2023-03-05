class RecipeModel {
  int? id;
  String? title;
  String? description;
  List<dynamic>? ingredients;

  RecipeModel(this.id, this.title, this.description, this.ingredients);

  // convert to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'ingredients': ingredients,
      };

  // convert from json
  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
        json['id'],
        json['title'],
        json['description'],
        json['ingredients'],
      );
}

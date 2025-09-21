import '../models/list_model.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';

class DatabaseService {

  // -----------------------
  // Fetch all lists for a user
  // -----------------------
  Future<List<ListModel>> getListsForUser(int userId) async {
    // TODO: Replace with your DB/API query
    // Example: fetch lists where user is owner or participant
    final lists = <ListModel>[];
    return lists;
  }

  // -----------------------
  // Fetch items for a list
  // -----------------------
  Future<List<ItemModel>> getItemsForList(int listId) async {
    final items = <ItemModel>[];

    return items;
  }

  // -----------------------
  // Fetch all lists a user is participating in
  // -----------------------
  Future<List<ListModel>> getListsForParticipant(int userId) async {
    final list = <ListModel>[];

    return list;
  }

  // -----------------------
  // Add a new item
  // -----------------------
  Future<void> addItem(ItemModel item) async {

    print('Added item: ${item.title}');
  }

  // -----------------------
  // Update an item
  // -----------------------
  Future<void> updateItem(int itemId) async {

    print("Updated item: ${itemId}");
  }

  // -----------------------
  // Delete an item
  // -----------------------
  Future<void> deleteItem(int itemId) async {

    print('Deleted item ${itemId}');
  }

  // -----------------------
  // Add a new list
  // -----------------------
  Future<void> addList(ListModel list) async {

    print("Added list: ${list.title}");
  }

  // -----------------------
  // Update a list
  // -----------------------
  Future<void> updateList(int listId) async {

    print("Updated list: ${listId}");
  }

  // -----------------------
  // Delete a list
  // -----------------------
  Future<void> deleteList(int listId) async {

    print("Deleted list with id $listId");
  }

  // -----------------------
  // Add a new user
  // -----------------------
  Future<void> addUser(UserModel user) async {

    print("Added user: ${user.username}");
  }

  // -----------------------
  // Update a user
  // -----------------------
  Future<void> updateUser(int userId) async {

    print("Updated user: ${userId}");
  }

  // -----------------------
  // Delete a user
  // -----------------------
  Future<void> deleteUser(int userId) async {

    print("Deleted user: ${userId}");
  }

  // -----------------------
  // Add a new participant
  // -----------------------
  Future<void> addParticipant(int listId, int userId) async {

    print("Added participant: ${userId} to list: ${listId}");
  }

  // -----------------------
  // Remove a participant
  // -----------------------
  Future<void> removeParticipant(int listId, int userId) async {

    print("Removed participant: ${userId} from list: ${listId}");
  }

}

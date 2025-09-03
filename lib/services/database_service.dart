// services/database_service.dart
import '../models/list_model.dart';
import '../models/item_model.dart';
import '../models/participates_model.dart';
//TODO: nothing works here, all workaround
class DatabaseService {
  // -----------------------
  // Fetch all lists for a user
  // -----------------------
  Future<List<ListModel>> getListsForUser(String userId) async {
    // TODO: Replace with your DB/API query
    // Example: fetch lists where user is owner or participant
    final lists = <ListModel>[];

    // Example pseudo data
    lists.add(
      ListModel(
        id: 1,
        ownerId: 1,
        title: 'Shopping List',
        type: 'shopping',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return lists;
  }

  // -----------------------
  // Fetch items for a list
  // -----------------------
  Future<List<ItemModel>> getItemsForList(int listId) async {
    final items = <ItemModel>[];

    // Example pseudo data
    items.add(
      ItemModel(
        id: 1,
        listId: listId,
        title: 'Milk',
        completed: false,
        amount: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return items;
  }

  // -----------------------
  // Fetch participants of a list
  // -----------------------
  Future<List<ParticipantModel>> getParticipantsForList(String listId) async {
    final participants = <ParticipantModel>[];

    // Example pseudo data
    participants.add(
      ParticipantModel(
        userId: 1,
        listId: 1,
      ),
    );

    return participants;
  }

  // -----------------------
  // Add a new item to a list
  // -----------------------
  Future<void> addItemToList(ItemModel item) async {
    // TODO: send POST request to backend or insert into DB
    print('Added item: ${item.title}');
  }

  // -----------------------
  // Toggle item completed
  // -----------------------
  Future<void> updateItemCompletion(ItemModel item, bool completed) async {
    // TODO: update DB or API
    print('Updated item ${item.title} completed = $completed');
  }

  Future<void> addList(ListModel list) async {
    // TODO: Insert into DB or call API
    print("Added list: ${list.title}");
  }

  Future<void> deleteList(String listId) async {
    // TODO: Delete from DB or API
    print("Deleted list with id $listId");
  }
}
